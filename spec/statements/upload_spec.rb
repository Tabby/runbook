require 'spec_helper'

RSpec.describe Runbook::Statements::Upload do
  let(:from) { 'my_file.txt' }
  let(:to) { '/root/my_file.txt' }
  let(:options) { { recursive: true } }
  let(:ssh_config) do
    {
      servers: ['server1.prod'],
      path: '/home/bobby_mcgee'
    }
  end
  let(:upload) do
    Runbook::Statements::Upload.new(
      from,
      to:,
      ssh_config:,
      options:
    )
  end

  it 'has a from' do
    expect(upload.from).to eq(from)
  end

  it 'has a to' do
    expect(upload.to).to eq(to)
  end

  it 'has options' do
    expect(upload.options).to eq(options)
  end

  it 'has an ssh_config' do
    expect(upload.ssh_config).to eq(ssh_config)
  end

  describe 'default_values' do
    let(:upload) { Runbook::Statements::Upload.new(from, to:) }
    it 'sets defaults for options' do
      expect(upload.options).to eq({})
    end

    it 'sets defaults for ssh_config' do
      expect(upload.ssh_config).to be_nil
    end
  end
end
