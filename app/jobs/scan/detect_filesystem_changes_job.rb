class Scan::DetectFilesystemChangesJob < ApplicationJob
  queue_as :scan

  # Find all files in the library that we might need to look at
  def filenames_on_disk(library)
    library.list_files(File.join("**", ApplicationJob.file_pattern))
  end

  # Get a list of all the existing filenames
  def known_filenames(library)
    library.model_files.reload.map(&:path_within_library)
  end

  def filter_out_common_subfolders(folders)
    matcher = /\/(#{ApplicationJob.common_subfolders.keys.join("|")})$/i
    folders.map { |f| f.gsub(matcher, "") }.uniq
  end

  def perform(library_id)
    library = Library.find(library_id)
    return if library.nil?
    return if Problem.create_or_clear(library, :missing, !library.storage_exists?)
    # Make a list of changed filenames using set XOR
    status[:step] = "jobs.scan.detect_filesystem_changes.building_filename_list" # i18n-tasks-use t('jobs.scan.detect_filesystem_changes.building_filename_list')
    changes = (known_filenames(library).to_set ^ filenames_on_disk(library)).to_a
    # Make a list of library-relative folders with changed files
    status[:step] = "jobs.scan.detect_filesystem_changes.building_folder_list" # i18n-tasks-use t('jobs.scan.detect_filesystem_changes.building_folder_list')
    folders_with_changes = changes.map { |f| File.dirname(f) }.uniq
    folders_with_changes = filter_out_common_subfolders(folders_with_changes)
    # Ignore root folder, however specified
    folders_with_changes.delete("/")
    folders_with_changes.delete(".")
    folders_with_changes.delete("./")
    folders_with_changes.compact_blank!
    # For each folder in the library with a change, find or create a model, then scan it
    status[:step] = "jobs.scan.detect_filesystem_changes.creating_models" # i18n-tasks-use t('jobs.scan.detect_filesystem_changes.creating_models')
    folders_with_changes.each { |path| Scan::CreateModelJob.perform_later(library.id, path) }
  end
end
