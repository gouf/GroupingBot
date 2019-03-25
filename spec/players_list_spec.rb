describe PlayersList do
  describe 'プレイヤーの追加と削除' do
    subject { PlayersList.new }
    let(:player_names) { %w[foo bar] }

    before { subject.insert_new_players_to_list(player_names) }

    context 'プレイヤーの追加をした場合' do
      it '指定した各プレイヤーが @list に追加される' do
        expect(subject.list).to eq player_names
      end
    end

    context 'プレイヤーの削除をした場合' do
      it '指定した各プレイヤーが @list から削除される' do
        subject.remove_players_from_list(player_names)

        expect(subject.list).to be_empty
      end
    end
  end
end
