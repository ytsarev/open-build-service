class AddDownloadPermissionsAndRole < ActiveRecord::Migration
  def self.up
    perm = StaticPermission.create :title => 'download_binaries'
    maint = Role.find_by_title 'maintainer'
    downl = Role.create :title => 'downloader'

    [maint,downl].each do |role|
      role.static_permissions << perm
    end
  end

  def self.down
    perm = StaticPermission.find_by_title('download_binaries')
    if perm
      perm.destroy
    end
  end
end