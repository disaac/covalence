require 'spec_helper'
require 'active_support/core_ext/hash'
require_relative File.expand_path(Covalence::GEM_ROOT, 'core/entities/input')

module Covalence
  RSpec.describe Input do
    let(:type) { 'terraform' }
    let(:input) { Fabricate(:input, type: type, raw_value: raw_value) }

    describe "validators" do
      it "does not allow remote inputs without 'type'" do
        expect{ Fabricate(:input, raw_value: { foo: 'baz' }) }.to raise_error(
          ActiveModel::StrictValidationFailed, /'type' not specified/)
      end
    end

    it "#type defaults to terraform" do
      expect(Fabricate(:input, raw_value: 'value').type).to eq('terraform')
    end

    context "with local input" do
      let(:raw_value) { "test" }

      it { expect(input.value).to eq(raw_value) }
    end

    context "with remote input" do
      let(:test_backend_class) { Covalence::TestBackend = Class.new(Object) }
      let(:raw_value) { { type: "test_backend.#{subcategory}", more: 'data' }.stringify_keys }

      let(:subcategory) { 'subcategory' }
      let(:remote_value) { 'remote_value' }

      before do
        expect(test_backend_class).to receive(:lookup).with(subcategory, raw_value).and_return(remote_value)
      end

      context "Terraform API response format" do
        let(:remote_value) do
          {
            "sensitive": false,
            "type": "string",
            "value": "foo"
          }
        end

        before(:each) do
          # force constants to re-init
          Kernel.silence_warnings {
            load File.join(Covalence::GEM_ROOT, '../covalence.rb')
          }
        end

        it 'returns the value' do
          expect(input.to_command_option).to eq("input = \"foo\"")
        end
      end
      it "returns the value for a non-local key by calling the backend lookup" do
        expect(input.value).to eq(remote_value)
        expect(input.raw_value).to_not eq(remote_value)
      end
    end

    describe "#to_command_option" do
      let(:raw_value) { "test" }

      before(:each) do
        # force constants to re-init
        Kernel.silence_warnings {
          load File.join(Covalence::GEM_ROOT, '../covalence.rb')
        }
      end

      context "with nil value" do
        let(:raw_value) { nil }

        it { expect(input.to_command_option).to eq("input = \"\"") }
      end

      context "interpolated shell value" do
        let(:raw_value) { "$(pwd)" }

        it { expect(input.to_command_option).to eq("input = \"#{`pwd`.chomp}\"") }
      end

      context "all other values" do
        it { expect(input.to_command_option).to eq("input = \"test\"") }
      end
    end
  end
end
