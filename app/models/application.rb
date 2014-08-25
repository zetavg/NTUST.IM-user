class Application < ActiveRecord::Base
  scope :scope_nav, -> { where('show_in_navigation = ?', true).order('priority ASC') }
  scope :scope_menu, -> { where('show_in_menu = ?', true).order('priority ASC') }

  after_save :update_cache

  def self.nav
    update_cache if !Rails.cache.read("application_nav")
    Rails.cache.read("application_nav")
  end

  def self.menu
    update_cache if !Rails.cache.read("application_menu")
    Rails.cache.read("application_menu")
  end

  def update_cache
    Rails.cache.write("application_nav", Application.scope_nav.to_a)
    Rails.cache.write("application_menu", Application.scope_menu.to_a)
  end

  def self.update_cache
    Rails.cache.write("application_nav", Application.scope_nav.to_a)
    Rails.cache.write("application_menu", Application.scope_menu.to_a)
  end
end
