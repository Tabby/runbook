require 'spec_helper'

RSpec.describe Runbook::Statements::TmuxCommand do
  let(:cmd) { "echo 'hi'" }
  let(:pane) { :target_pane }
  let(:command) do
    Runbook::Statements::TmuxCommand.new(cmd, pane)
  end

  it 'has a command' do
    expect(command.cmd).to eq(cmd)
  end

  it 'has pane' do
    expect(command.pane).to eq(pane)
  end
end
