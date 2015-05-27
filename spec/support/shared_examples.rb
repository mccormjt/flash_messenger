# These shared example test that a subject's accessor method is:
#
#   A) Publicly exposed
#   B) Not nil
#   c) Result "equal" to the `let` with the same name in context
#
# @param [Symbol] Method name as symbol
# @param [*args] Arbitrary arguments to pass to the `send` call
#
RSpec.shared_examples 'a public accessor method' do |target, *args|
  let(:result) do
    subject.public_send(target, *(args.map { |i| public_send(i) }))
  end

  let(:expected) do
    public_send(target)
  end

  it "publicly exposes ##{target}" do
    expect(result).not_to be_nil
  end

  it 'has expected values' do
    expect(result).to eq(expected)
  end
end
