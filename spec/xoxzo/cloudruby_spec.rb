require 'spec_helper'
require 'pp'

include Xoxzo::Cloudruby

describe Xoxzo::Cloudruby do
  before(:each) do
    sid = ENV['XOXZO_API_SID']
    token = ENV['XOXZO_API_AUTH_TOKEN']
    @test_recipient = ENV['XOXZO_API_TEST_RECIPIENT']
    @test_mp3_url = ENV['XOXZO_API_TEST_MP3']
    @xc = XoxzoClient.new(sid,token)
    end

  it 'has a version number' do
    expect(Xoxzo::Cloudruby::VERSION).not_to be nil
  end

  xit 'test send sms success and get sent status' do
    res = @xc.send_sms(message: "こんにちはRuby Lib です", recipient: @test_recipient, sender: "8108012345678")
    expect(res.errors).to be nil
    expect(res.message).to eq({})
    expect(res.messages[0].key?('msgid')).to be true

    sleep(2)

    msgid = res.messages[0]['msgid']
    res = @xc.get_sms_delivery_status(msgid=msgid) # this is temprary msgid 2016/05/19
    expect(res.errors).to be nil
    expect(res.message.key?('msgid')).to be true
    expect(res.message.key?('cost')).to be true
    expect(res.messages).to eq []
  end

  it 'test send sms faile, bad recipient format' do
    res = @xc.send_sms(message: "こんにちはRuby Lib です", recipient: "+0808012345678", sender: "8108012345678")
    expect(res.errors).to eq 400
    expect(res.message.key?('recipient')).to be true
    expect(res.messages).to eq []
  end

  it 'test get sms status fail, bad msgid' do
    res = @xc.get_sms_delivery_status(msgid="0123456789")
    expect(res.errors).to eq 404
    expect(res.message).to eq [] # this is a bug currently
    # expect(res.message).to be nil
    expect(res.messages).to eq []
  end

  it 'test get sent sms list all' do
    res = @xc.get_sent_sms_list()
    expect(res.errors).to be nil
    expect(res.message).to eq({}) # this is a bug currently
    expect(res.messages[0].key?('cost')).to be true
    # pp res.messages
  end

  it 'test get sent sms list with specifice date' do
    res = @xc.get_sent_sms_list(sent_date: "=2016-05-18")
    expect(res.errors).to be nil
    expect(res.message).to eq({})
    if  res.messages != []
      expect(res.messages[0].key?('cost')).to be true
      #pp res.messages
    end
  end

  xit 'test simple voice playback success' do
    res = @xc.call_simple_playback(caller:"810812345678",recipient: @test_recipient,recording_url: @test_mp3_url)
    expect(res.errors).to be nil
    expect(res.message).to eq({})
    expect(res.messages[0].key?('callid')).to be true

    callid = res.messages[0]['callid']
    res = @xc.get_simple_playback_status(callid: callid)
    expect(res.errors).to be nil
    expect(res.message.key?('callid')).to be true
    expect(res.messages).to eq []
  end

  it 'test get simple playback status, fail' do
    res = @xc.get_simple_playback_status(callid: "dabd8e76-390f-421c-87b5-57f31339d0c5")
    expect(res.errors).to be 404
    expect(res.message).to eq({})
    expect(res.messages).to eq []
  end
end
