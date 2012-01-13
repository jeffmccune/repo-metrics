module PuppetLabs
  module Metrics
    module LOC
      class Release
        attr_accessor :commits
        attr_accessor :git_log_file
        attr_accessor :authors
        attr_accessor :extra_hash
        attr_reader   :lines_added_by_author
        attr_reader   :lines_removed_by_author

        def initialize(git_log_file = nil)
          @git_log_file = git_log_file
          @extra_hash = Hash.new
          self.reload
        end

        def reload
          @commits = Array.new
          @authors = Hash.new
          @lines_added_by_author = Hash.new(0)
          @lines_removed_by_author = Hash.new(0)
          if @git_log_file then
            self.load_file(@git_log_file)
          end
          self
        end

        def load_file(file)
          lines = File.readlines(file).collect { |line| line.chomp }
          state = Hash.new(0)
          lines.each do |line|
            case line
            when /^\s*$/
              @commits << state
              state = Hash.new(0)
            when /^(\d+)\s+(\d+)/
              state['added'] += $1.to_i
              state['removed'] += $2.to_i
            when /@/
              state['author'] = line.split(',')[0]
              state['commiter'] = line.split(',')[1]
            end
          end
          @commits.each do |commit|
            @lines_added_by_author[commit['author']] += commit['added']
            @lines_removed_by_author[commit['author']] += commit['removed']
          end
          self
        end

        def lines_added(author=nil)
          @commits.inject(0) do |memo, k|
            memo += k['added']
            memo
          end
        end

        def lines_removed(author=nil)
          @commits.inject(0) do |memo, k|
            memo += k['removed']
            memo
          end
        end

        def report
          total_added = @lines_added_by_author.inject(0) { |memo, (k,v)| memo += v; memo; }
          total_removed = @lines_removed_by_author.inject(0) { |memo, (k,v)| memo += v; memo; }
          hsh = { 'lines_removed' => @lines_removed_by_author,
            'lines_added'   => @lines_added_by_author,
            'total_added'   => total_added,
            'total_removed' => total_removed,
          }
          @extra_hash.merge(hsh)
        end
      end
    end
  end
end
