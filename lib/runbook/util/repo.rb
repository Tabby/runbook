module Runbook
  module Util
    module Repo
      FILE_ID = 'data'.freeze
      FILE_PERMISSIONS = 0o600

      def self.load(metadata)
        title = metadata[:book_title]
        file = _file(title)
        return unless File.exist?(file)

        msg = "Repo file #{file} detected. Loading previous state..."
        metadata[:toolbox].output(msg)
        metadata[:repo] = ::YAML.load_file(file)
      end

      def self.save(repo, book_title:)
        File.open(_file(book_title), 'w', FILE_PERMISSIONS) do |f|
          f.write(repo.to_yaml)
        end
      end

      def self.delete(title)
        FileUtils.rm_f(_file(title))
      end

      def self._file(book_title)
        "#{Dir.tmpdir}/runbook_#{FILE_ID}_#{ENV.fetch('USER', nil)}_#{_slug(book_title)}.yml"
      end

      def self._slug(title)
        title.titleize.gsub(%r{[/\s]+}, '').underscore.dasherize
      end

      def self.register_save_repo_hook(base)
        base.register_hook(
          :save_repo_hook,
          :after,
          Object
        ) do |_object, metadata|
          repo = metadata[:repo]
          title = metadata[:book_title]
          Runbook::Util::Repo.save(repo, book_title: title)
        end
      end

      def self.register_delete_stored_repo_hook(base)
        base.register_hook(
          :delete_stored_repo_hook,
          :after,
          Runbook::Entities::Book
        ) do |_object, metadata|
          title = metadata[:book_title]
          Runbook::Util::Repo.delete(title)
        end
      end
    end
  end
end
