module Flow
  class Base
    class << self
      def unstarted_stories!
        @stories = nil
        unstarted_stories
      end

      def unstarted_stories
        conditions = {
          current_state: "unstarted"
        }
        project.stories.all(conditions)
      end

      def started_stories
        conditions = {
          current_state: "started",
          owned_by: ENV['PIVOTAL_USERNAME']
        }
        project.stories.all(conditions)
      end

      def project
        return @project if @project
        PivotalTracker::Client.token(
          ENV['PIVOTAL_EMAIL'],
          ENV['PIVOTAL_PASSWORD']
        )
        PivotalTracker::Client.token = ENV['PIVOTAL_TOKEN']
        PivotalTracker::Client.timeout = 50
        @project = PivotalTracker::Project.find(ENV['PIVOTAL_PROJECT_ID'])
      end
    end
  end
end
