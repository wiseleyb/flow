module Flow
  class Story < Base
    def initialize(story_id, cmd)
      @project = Flow::Base.project
      @story = @project.stories.find(story_id)
      @cmd = cmd
    end

    def piv_story
      @story
    end

    def branch_name
      "#{@story.story_type}/#{@story.name.downcase.gsub(' ', '-')}-#{@story.id}"
    end

    def start
      if @story.estimate.to_i < 0
        @cmd.put "Estimate (0,1,2,3): ", false
        points = gets
      else
        points = @story.estimate.to_i
      end
      owned_by = @story.owned_by || ENV['PIVOTAL_USERNAME']
      res = @story.update(
        owned_by: owned_by,
        estimate: points,
        current_state: :started)

      if res.errors.empty?
        @cmd.get('git status')
        @cmd.get('git stash')
        @cmd.get('git checkout master')
        @cmd.get('git pull origin master')
        @cmd.get("git checkout -b #{branch_name}")
        @cmd.get('git stash pop')
        @cmd.get('git status')
      else
        @cmd.put 'Error!'
        @cmd.put res.to_yaml
      end
    end

    def finish
      put "Found story: #{piv_story.name}"
      fname = "flow-#{piv_story.id}-commit-msg.txt"
      commit_msg = []
      commit_msg << piv_story.name
      commit_msg << ''
      commit_msg << piv_story.description
      commit_msg << ''
      commit_msg << 'Pivotal Story:'
      commit_msg << piv_story.url
      File.write(fname, commit_msg.join("\n"))
      @cmd.vim("git commit -F #{fname} -e")
      @cmd.get("rm #{fname}")
    end

    def push
      @cmd.get("git push origin #{branch_name}")
      @cmd.get('git checkout master')
    end

    def merge_master
      @cmd.get('git stash')
      @cmd.get('git checkout master')
      @cmd.get('git pull origin master')
      @cmd.get("git checkout #{branch_name}")
      @cmd.vim('git rebase master -i')
      @cmd.get("git push origin #{branch_name} --force")
      @cmd.get('git checkout master')
      @cmd.get("git merge #{branch_name}")
      @cmd.put 'Marking story finished'
      @story.update(current_status: :finished)
    end

    def merge_staging
      @cmd.get('git checkout master')
      @cmd.get('git pull origin master')
      @cmd.get('git checkout staging')
      @cmd.get('git pull origin staging')
      @cmd.get('git merge master')
      @cmd.get('git push origin staging')
      @cmd.get('git checkout master')
      @cmd.get("git branch -d #{branch_name}")
      @cmd.put 'Marking story delivered'
      @story.update(current_status: :delivered)
    end

    def undo
      res = @story.update(
        owned_by: nil,
        estimate: nil,
        current_state: :unstarted
      )

      if res.errors.empty?
        @cmd.put "Story '#{@story.name}' has been undone in Pivotal"
        @cmd.get('git status')
        @cmd.get('git stash')
        @cmd.get('git checkout master')
        @cmd.get("git branch -d #{branch_name}")
        @cmd.put "Branch #{branch_name} has been deleted"
        @cmd.put "Any work that was in progress is in git stash."
        @cmd.put "Use 'git stash apply' to recover"
      else
        @cmd.put 'Error!'
        @cmd.put res.to_yaml
      end
    end
  end
end
