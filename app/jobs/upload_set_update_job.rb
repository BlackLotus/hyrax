class UploadSetUpdateJob < ActiveJob::Base
  include Hydra::PermissionsQuery
  include CurationConcerns::Messages

  queue_as :upload_set_update

  attr_accessor :saved, :denied

  # This copies metadata from the passed in attribute to all of the works that
  # are members of the given upload set
  def perform(login, upload_set_id, titles, attributes, visibility)
    @login = login
    @saved = []
    @denied = []
    @upload_set_id = upload_set_id

    titles ||= {}
    attributes = attributes.merge(visibility: visibility)

    update(upload_set, titles, attributes)
    send_user_message
  end

  private

    def upload_set
      @upload_set ||= UploadSet.find_or_create(@upload_set_id)
    end

    def update(upload_set, titles, attributes)
      upload_set.works.each do |work|
        title = titles[work.id] if titles[work.id]
        next unless update_work(work, title, attributes)
        # TODO: stop assuming that files only belong to one work
        saved << work
      end

      upload_set.update(status: ["Complete"])
    end

    def send_user_success_message
      return unless CurationConcerns.config.callback.set?(:after_upload_set_update_success)
      CurationConcerns.config.callback.run(:after_upload_set_update_success, user, upload_set)
    end

    def send_user_failure_message
      return unless CurationConcerns.config.callback.set?(:after_upload_set_update_failure)
      CurationConcerns.config.callback.run(:after_upload_set_update_failure, user, upload_set)
    end

    def send_user_message
      if denied.empty?
        send_user_success_message unless saved.empty?
      else
        send_user_failure_message
      end
    end

    def user
      @user ||= User.find_by_user_key(@login)
    end

    def update_work(work, title, attributes)
      unless user.can? :edit, work
        ActiveFedora::Base.logger.error "User #{user.user_key} DENIED access to #{work.id}!"
        denied << work
        return
      end

      work.title = title if title
      work_actor(work, attributes).update
    end

    def work_actor(work, attributes)
      CurationConcerns::GenericWorkActor.new(work, user, attributes)
    end
end
