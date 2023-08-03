require 'spec_helper'

RSpec.describe Runbook::Statements::Capture do
  let(:cmd) { "echo 'hi'" }
  let(:into) { :capture_result }
  let(:ssh_config) do
    {
      servers: ['server1.prod'],
      parallelization: {
        strategy: :groups,
        limit: 2,
        wait: 2
      },
      path: '/home/bobby_mcgee',
      user: 'bobby_mcgee',
      group: 'bobby_mcgee',
      env: { rails_env: 'production' },
      umask: '077'
    }
  end
  let(:raw) { true }
  let(:strip) { false }
  let(:capture) do
    Runbook::Statements::Capture.new(
      cmd,
      into:,
      ssh_config:,
      raw:,
      strip:
    )
  end

  it 'has a command' do
    expect(capture.cmd).to eq(cmd)
  end

  it 'has an into' do
    expect(capture.into).to eq(into)
  end

  it 'has an ssh_config' do
    expect(capture.ssh_config).to eq(ssh_config)
  end

  it 'has a raw param' do
    expect(capture.raw).to eq(raw)
  end

  it 'has a strip param' do
    expect(capture.strip).to eq(strip)
  end

  describe 'default_values' do
    let(:capture) { Runbook::Statements::Capture.new(cmd, into:) }
    it 'sets defaults for ssh_config' do
      expect(capture.ssh_config).to be_nil
    end

    it 'sets defaults for raw' do
      expect(capture.raw).to be_falsey
    end

    it 'sets defaults for strip' do
      expect(capture.strip).to be_truthy
    end
  end
end
