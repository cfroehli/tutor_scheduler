# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Teacher, type: :model do
  let!(:french) { create(:language, :french) }
  let(:teacher) { create(:teacher) }

  it 'can add a new language' do
    expect(teacher.languages).not_to include(french)
    expect do
      teacher.add_language(french.id)
      teacher.reload
    end.to change(teacher.languages, :count).by(1)
    expect(teacher.languages).to include(french)
  end

  it 'ignore already added languages' do
    expect do
      teacher.add_language(french.id)
      teacher.reload
    end.to change(teacher.languages, :count).by(1)
    expect(teacher.languages).to include(french)

    expect do
      teacher.add_language(french.id)
      teacher.reload
    end.not_to change(teacher.languages, :count)
  end
end
