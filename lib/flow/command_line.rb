module Flow
  class CommandLine
    def initialize(input=STDIN, output=STDOUT, *args)
      @input = input
      @output = output
      @args = *args
    end

    def run!
      case @args.first.first
      when 'start'
        start
      when 'finish'
        finish
      when 'push'
        push
      when 'merge_master'
        merge_master
      when 'merge_staging'
        merge_staging
      when 'undo'
        undo
      end
      return 0
    end

    def start
      stories = Flow::Base.unstarted_stories
      stories.each_with_index do |s, idx|
        desc = "#{idx}. [#{s.story_type}] #{s.name}"
        desc << " (#{s.estimate} pts)"
        desc << " owner: #{s.owned_by}"
        put desc
      end
      put "Start which story? ", false
      choice = @input.gets
      story = stories[choice.to_i]
      if story
        Flow::Story.new(story.id, self).start
      else
        put "Story #{choice.chomp} not found."
      end
    end

    def finish
      with_story { @story.finish }
    end

    def push
      with_story { @story.push }
    end

    def merge_master
      with_story { @story.merge_master }
    end

    def merge_staging
      with_story { @story.merge_staging }
    end

    def with_story(&block)
      story_id = get('git rev-parse --abbrev-ref HEAD').split('-').last.chomp
      if story_id
        @story = Flow::Story.new(story_id, self)
        if @story
          yield
        else
          put "Could not find story '#{story_id}'"
          put 'Aborting'
        end
      else
        put 'Could not located story id'
        put 'Make sure you are on the right branch'
        put 'Aborting'
      end
    end

    def undo
      stories = Flow::Base.started_stories
      stories.each_with_index do |s, idx|
        desc = "#{idx}. [#{s.story_type}] #{s.name}"
        desc << " (#{s.estimate} pts)"
        desc << " owner: #{s.owned_by}"
        put desc
      end
      put "Undo which story? ", false
      choice = @input.gets
      story = stories[choice.to_i]
      if story
        flow_story = Flow::Story.new(story.id, self)
        put 'This will unstart the story in Pivotal'
        put 'This will stash your work (if any exists)'
        put "This will delete the branch '#{flow_story.branch_name}'"
        put 'Are you sure?'
        put 'Enter "yes" to continue: ', false
        choice = @input.gets
        if choice.chomp.to_s == 'yes'
          flow_story.undo
        else
          put 'Aborted. No action taken'
        end
      else
        put "Story #{choice.chomp} not found."
      end
    end

    def put(string, newline=true)
      @output.print(newline ? string + "\n" : string)
    end

    def sys(cmd)
      put cmd
      system "#{cmd} > /dev/null 2>&1"
    end

    def vim(cmd)
      put cmd
      system "#{cmd} < `tty` > `tty`"
    end

    def get(cmd)
      put cmd
      `#{cmd}`
    end
  end
end
