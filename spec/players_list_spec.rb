class EventMock
  def send_message(message)
    message
  end
end

describe PlayersList do
  subject { PlayersList.new }

  describe 'プレイヤーのリストをユーザに通知' do
    context '@list が空の場合' do
      it '空である旨のメッセージが送信される' do
        result = subject.notify_players_list(event: EventMock.new)
        expect(result).to eq BotMessage.no_players
      end
    end

    context '@list に値がある場合' do
      before { subject.insert_new_players_to_list(%w[foo bar]) }

      it 'プレイヤーのリストがメッセージとして送信される' do
        result = subject.notify_players_list(event: EventMock.new)
        expect(result).to eq BotMessage.players_list(%w[foo bar])
      end
    end
  end

  describe 'プレイヤーの追加と削除' do
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
