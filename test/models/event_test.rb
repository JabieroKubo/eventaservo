# frozen_string_literal: true

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  setup do
    @event = events(:one)
  end

  test 'evento havas kreinton' do
    assert_not_nil Event.reflect_on_association(:user)
  end

  test 'evento havas landon' do
    assert_not_nil Event.reflect_on_association(:country)
  end

  test 'evento havas ŝatatojn' do
    assert_not_nil Event.reflect_on_association(:country)
  end

  test 'evento havas partoprenantojn' do
    assert_not_nil Event.reflect_on_association(:participants)
  end

  test 'titolo necesas' do
    event       = events(:one)
    event.title = nil
    assert event.invalid?
  end

  test 'priskribo necesas' do
    event             = events(:one)
    event.description = nil
    assert event.invalid?
  end

  test 'urbo necesas' do
    event = events(:one)
    event.city = nil
    assert event.invalid?
  end

  test 'evento sen lando devas fiaski' do
    event = events(:one)
    event.country_id = nil
    assert event.invalid?
  end

  test 'komenca dato necesas' do
    event = events(:one)
    event.date_start = nil
    assert event.invalid?
  end

  test 'fina dato necesas' do
    event = events(:one)
    event.date_end = nil
    assert event.invalid?
  end

  test 'kodo necesas' do
    event = events(:one)
    event.code = nil
    assert event.invalid?
  end

  test 'fina dato devas esti post komenca dato' do
    event            = events(:one)
    event.date_start = Date.today
    event.date_end   = Date.today - 1.day
    assert_not event.save
  end

  test 'forigas kaj malforigas la eventon, sed ne el la datumbazo' do
    @event.delete!
    assert_equal @event.deleted, true

    @event.undelete!
    assert_equal @event.deleted, false
  end

  test 'serĉado' do
    event = events(:brazilo)
    assert Event.search('brazilo').exists?(id: event.id)
  end

  test 'priskribo ne povas esti pli ol 400 signoj' do
    @event.description = SecureRandom.hex(201) # Pli ol 400 signoj
    assert @event.invalid?
  end

  test 'korektas la titolan skribmanieron' do
    @event.update_attribute(:title, 'GRANDA TITOLO')
    assert_equal 'Granda Titolo', @event.title

    @event.update_attribute(:title, 'malgranda titolo')
    assert_equal 'Malgranda Titolo', @event.title

    @event.update_attribute(:title, 'BONA Skribita Titolo')
    assert_equal 'BONA Skribita Titolo', @event.title
  end

  test 'retejo devas enhavi http se ankoraŭ ne havas ĝin' do
    site = 'google.com'
    @event.update_attribute(:site, site)
    assert_equal "http://#{site}", @event.site
  end

  test 'ne aldonu http se retejo jam havas ĝin' do
    site = 'https://google.com'
    @event.update_attribute(:site, site)
    assert_equal site, @event.site
  end

  test 'ne aldonu http se ne estas retejo' do
    @event.update!(site: nil)
    assert_nil @event.site

    @event.update!(site: '')
    assert_nil @event.site

    @event.update!(site: ' ')
    assert_nil @event.site

    @event.update!(site: 'google.com')
    assert_equal 'http://google.com', @event.site
  end

  test 'forigas malpermesatajn signojn el urbonomo' do
    @event.update_attribute(:city, 'urbo / alia urbo')
    assert_equal 'urbo  alia urbo', @event.city
  end

  test 'geocoder, dum provoj, devas informi la NY adreson' do
    event = events(:usono)
    event.geocode
    event.save
    assert_equal (40.7143528), event.latitude
    assert_equal (-74.0059731), event.longitude
  end
end
