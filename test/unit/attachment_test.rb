require "test_helper"

class AttachmentTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "should be invalid without an attachable" do
    assert_not build(:file_attachment, attachable: nil).valid?
  end

  test "should be invalid without a title" do
    attachment = build(:file_attachment, title: nil)
    assert_not attachment.valid?
  end

  test "should be valid without ISBN" do
    attachment = build(:file_attachment, isbn: nil)
    assert attachment.valid?
  end

  test "should be valid with blank ISBN" do
    attachment = build(:file_attachment, isbn: "")
    assert attachment.valid?
  end

  test "should be invalid with an ISBN that's not in ISBN-10 or ISBN-13 format" do
    attachment = build(:file_attachment, isbn: "invalid-isbn")
    assert_not attachment.valid?
  end

  test "should be valid with ISBN in ISBN-10 format" do
    attachment = build(:file_attachment, isbn: "0261102737")
    assert attachment.valid?
  end

  test "should be valid with ISBN in ISBN-13 format" do
    attachment = build(:file_attachment, isbn: "978-0261103207")
    assert attachment.valid?
  end

  test "should be valid without Command paper number" do
    attachment = build(:file_attachment, command_paper_number: nil)
    assert attachment.valid?
  end

  test "should be valid with blank Command paper number" do
    attachment = build(:file_attachment, command_paper_number: "")
    assert attachment.valid?
  end

  ["C.", "Cd.", "Cmd.", "Cmnd.", "Cm.", "CP"].each do |prefix|
    test "should be valid when the Command paper number starts with '#{prefix}'" do
      attachment = build(:file_attachment, command_paper_number: "#{prefix} 1234")
      assert attachment.valid?
    end
  end

  ["NA", "C", "Cd ", "CM.", "CP."].each do |prefix|
    test "should be invalid when the command paper number starts with '#{prefix}'" do
    attachment = build(:file_attachment, command_paper_number: "#{prefix} 1234")
    assert_not attachment.valid?
    expected_message = "is invalid. The number must start with one of #{Attachment::VALID_COMMAND_PAPER_NUMBER_PREFIXES.join(', ')}, followed by a space. If a suffix is provided, it must be a Roman numeral. Example: CP 521-IV"
    assert attachment.errors[:command_paper_number].include?(expected_message)
  end

  ["-I", "-IV", "-VIII"].each do |suffix|
    test "should be valid when the command paper number ends with '#{suffix}'" do
      attachment = build(:file_attachment, command_paper_number: "C. 1234#{suffix}")
      assert attachment.valid?
    end
  end

  ["-i", "-Iv", "VIII"].each do |suffix|
    test "should be invalid when the command paper number ends with '#{suffix}'" do
      attachment = build(:file_attachment, command_paper_number: "C. 1234#{suffix}")
      assert_not attachment.valid?
    end
  end

  test "should be invalid when the command paper number has no space after the prefix" do
    attachment = build(:file_attachment, command_paper_number: "C.1234")
    assert_not attachment.valid?
  end

  test "should be valid without a unique_reference" do
    attachment = build(:file_attachment, unique_reference: nil)
    assert attachment.valid?
  end

  test "should be invalid with a long unique_reference" do
    attachment = build(:file_attachment, unique_reference: SecureRandom.hex(300))
    assert_not attachment.valid?
  end

  test "should generate list of parliamentary sessions" do
    earliest_session = "1951-52"
    now = Time.zone.now
    latest_session = [now.strftime("%Y"), (now + 1.year).strftime("%y")].join("-")
    assert_equal latest_session, Attachment.parliamentary_sessions.first
    assert_equal earliest_session, Attachment.parliamentary_sessions.last
  end

  test "#is_command_paper? should be true if attachment has a command paper number or is flagged as an unnumbered command paper" do
    assert_not build(:html_attachment, command_paper_number: nil,     unnumbered_command_paper: false).is_command_paper?
    assert build(:html_attachment, command_paper_number: "12345", unnumbered_command_paper: false).is_command_paper?
    assert build(:html_attachment, command_paper_number: nil,     unnumbered_command_paper: true).is_command_paper?
  end

  test "#is_act_paper? should be true if attachment has an act paper number or is flagged as an unnumbered act paper" do
    assert_not build(:html_attachment, hoc_paper_number: nil,     unnumbered_hoc_paper: false).is_act_paper?
    assert build(:html_attachment, hoc_paper_number: "12345", unnumbered_hoc_paper: false).is_act_paper?
    assert build(:html_attachment, hoc_paper_number: nil,     unnumbered_hoc_paper: true).is_act_paper?
  end

  test "prevents saving of abstract Attachment class" do
    assert_raises RuntimeError do
      Attachment.new(attachable: Consultation.new, title: "Attachment").save
    end
  end

  test "#rtl_locale? should be false for non-rtl locale" do
    assert_not build(:html_attachment, locale: "fr").rtl_locale?
  end

  test "#rtl_locale? should be true for an rtl locale" do
    assert build(:html_attachment, locale: "ar").rtl_locale?
  end

  test "#rtl_locale? should be false for a blank locale" do
    assert_not build(:html_attachment, locale: nil).rtl_locale?
    assert_not build(:html_attachment, locale: "").rtl_locale?
  end

  test "#content_id is set on save" do
    attachment = build(:html_attachment)
    assert attachment.content_id.nil?
    attachment.save
    assert attachment.content_id =~ /^[\w\d]{8}-[\w\d]{4}-[\w\d]{4}-[\w\d]{4}-[\w\d]{12}$/
  end

  test "delete sets deleted true" do
    attachment = create(:file_attachment)
    attachment.delete
    assert attachment.deleted?
  end

  test "destroy sets deleted true" do
    attachment = create(:file_attachment)
    attachment.destroy
    assert attachment.deleted?
  end
end
