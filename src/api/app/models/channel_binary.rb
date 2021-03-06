class ChannelBinary < ActiveRecord::Base

  belongs_to :channel_binary_list
  belongs_to :project
  belongs_to :repository
  belongs_to :architecture

  def self.find_by_project_and_package(project, package)
    project = Project.find_by_name(project) if project.is_a? String
    cbs = Array.new
    # find direct refences
    cbs += ChannelBinary.where(project: project, package: package)
    # find refences where project comes from the default
    cbs += ChannelBinary.joins(:channel_binary_list).where('channel_binaries.project_id = NULL and channel_binary_lists.project_id = ? and package = ?', project, package)
    return cbs
  end

  def create_channel_package(pkg, maintenanceProject)
    cp = self.channel_binary_list.channel.package
    name = self.channel_binary_list.channel.name

    # does it exist already? then just skip it
    return if Package.exists_by_project_and_name(pkg.project.name, name)

    # do we need to take care about a maintained list from upper project?
    if maintenanceProject and not maintenanceProject.maintained_projects.include? cp.project
      # not a maintained project here
      return
    end

    # create a package beside me
    tpkg = Package.new(:name => name, :title => cp.title, :description => cp.description)
    pkg.project.packages << tpkg
    tpkg.store

    # branch sources
    tpkg.branch_from(cp.project.name, cp.name)
    tpkg.sources_changed

    # branch repositories
    pkg.project.branch_to_repositories_from(cp.project, tpkg, true)
  end
end
