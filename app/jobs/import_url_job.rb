require 'uri'
require 'tmpdir'
require 'browse_everything/retriever'

# Given a FileSet that has an import_url property,
# download that file and put it into Fedora
# Called by AttachFilesToWorkJob (when files are uploaded to s3)
# and CreateWithRemoteFilesActor when files are located in some other service.
class ImportUrlJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  before_enqueue do |job|
    operation = job.arguments.last
    operation.pending_job(job)
  end

  # @param [FileSet] file_set
  # @param [Hyrax::BatchCreateOperation] operation
  def perform(file_set, operation)
    operation.performing!
    user = User.find_by_user_key(file_set.depositor)
    uri = URI(file_set.import_url)
    copy_remote_file(uri) do |f|
      # reload the FileSet once the data is copied since this is a long running task
      file_set.reload

      # We invoke the FileSetActor in a synchronous way so that this tempfile is available
      # when IngestFileJob is invoked. If it was asynchronous the IngestFileJob may be invoked
      # on a machine that did not have this temp file on it's file system.
      # NOTE: The return status may be successful even if the content never attaches.
      if Hyrax::Actors::FileSetActor.new(file_set, user).create_content(f, 'original_file', false)
        operation.success!
      else
        # send message to user on download failure
        Hyrax.config.callback.run(:after_import_url_failure, file_set, user)
        operation.fail!(file_set.errors.full_messages.join(' '))
      end
    end
  end

  private

    # Download file from uri, yields a block with a file in a temporary directory.
    # It is important that the file on disk has the same file name as the URL,
    # because when the file in added into Fedora the file name will get persisted in the
    # metadata.
    # @param uri [URI] the uri of the file to download
    # @yield [IO] the stream to write to
    def copy_remote_file(uri)
      filename = File.basename(uri.path)
      Dir.mktmpdir do |dir|
        File.open(File.join(dir, filename), 'wb') do |f|
          retriever = BrowseEverything::Retriever.new
          retriever.retrieve('url' => uri) do |chunk|
            f.write(chunk)
          end
          f.rewind
          yield f
        end
      end
    end
end
