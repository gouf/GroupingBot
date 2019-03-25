describe BotMessage do
  context '引数 name がnil だった場合' do
    subject { BotMessage }

    it '#added は nil を返す' do
      expect(subject.added(nil)).to be_nil
    end

    it '#already_added は nil を返す' do
      expect(subject.already_added(nil)).to be_nil
    end

    it '#removed は nil を返す' do
      expect(subject.removed(nil)).to be_nil
    end

    it '#no_members は nil を返す' do
      expect(subject.no_members(nil)).to be_nil
    end
  end
end
