module AdminLegacyAssociationsHelper
  def set_all_legacy_associations
    tag_specialist_sectors
    click_button "Save"
  end

  def check_associations_have_been_saved
    check_specialist_sectors
  end

  def check_legacy_associations_are_displayed_on_admin_page
    assert_selected_specialist_sectors_are_displayed
  end

private

  def tag_specialist_sectors
    select "Oil and Gas: Wells", from: "Primary specialist sector tag"
    select "Oil and Gas: Fields", from: "Additional specialist sectors"
    select "Oil and Gas: Offshore", from: "Additional specialist sectors"
  end

  def check_specialist_sectors
    assert_equal "WELLS", Publication.last.primary_specialist_sector_tag
    assert_equal %w[FIELDS OFFSHORE], Publication.last.secondary_specialist_sector_tags
  end

  def assert_selected_specialist_sectors_are_displayed
    assert has_css? ".primary-specialist-sector li", text: "Oil and Gas: Wells"
    refute has_css? ".primary-specialist-sector li", text: "Oil and Gas: Fields"
    assert has_css? ".secondary-specialist-sectors li", text: "Oil and Gas: Fields"
    assert has_css? ".secondary-specialist-sectors li", text: "Oil and Gas: Offshore"
    refute has_css? ".secondary-specialist-sectors li", text: "Oil and Gas: Wells"
  end
end

World(AdminLegacyAssociationsHelper)
