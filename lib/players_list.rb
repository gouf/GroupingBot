# TODO: 実際に動作するか検証する
# TODO: テストコードを追加する
# FIXME: エラーがあれば修正する

# 各参加者のリストを管理・通知する
class PlayersList
  def initialize
    @list = []
  end

  # 指定された各プレイヤー名をリストに追加
  def insert_new_players_to_list(player_names)
    player_names.each do |name|
      @list << name if @list.exclude?(name)
    end
  end

  # 指定された各プレイヤー名をリストから削除
  def remove_players_from_list(player_names)
    player_names.each do |name|
      @list.delete(name) if @list.include?(name)
    end
  end

  # プレイヤーのリストをユーザに通知する
  def notify_players_list(event:)
    if @list.empty?
      event.send_message(BotMessage.no_players)
    else
      event.send_message(BotMessage.players_list(@list))
    end
  end

  # ボイスチャットに参加しているプレイヤー一覧からチーム分けを作成する
  def make_two_teams_by_voice_chat_players(event:)
    # オリジナルの参加者リストを保持
    players_list_original = @list.dup

    if event.user.voice_channel.nil?
      event.send_message(BotMessage.no_voice_channel_members)
      return
    end

    if no_players?
      event.send_message(BotMessage.need_two_or_more_players)
      return
    end

    clear_list! # 一時的にリストを空にする


    insert_new_players(
      event.user.voice_channel.users.map(&:name)
    )

    event.send_message(
      BotMessage.tagged_team_list(
        divide_to_two_teams
      )
    )

    # 参加者リストをオリジナルのものに戻す
    @list = players_list_original
  end

  # 差分をユーザに通知するため、すでにリストにある名前とそうでない名前を振り分ける
  # * 追加したい場合は「リストに含まれていない場合」
  # * 削除したい場合は「リストに含まれている場合」
  # がマッチ条件になる
  def filter_matched_or_not(new_players, to_remove: false)
    matched = []
    unmatched = []

    matcher = to_remove ? :include? : :exclude?

    new_players.each do |player_name|
      if @list.method(matcher).call(player_name)
        matched << player_name
      else
        unmatched << player_name
      end
    end

    [matched, unmatched]
  end

  # チーム分けにはプレイヤーが2人以上必要
  def no_players?
    @list.size < 2
  end

  # 管理しているプレイヤー一覧を破棄する
  def clear_list!
    @list = []
  end

  # 与えられたプレイヤー名のリストから2つのチームを作成
  def divide_to_two_teams
    @list.sort_by { rand }
         .each_slice((players_list.size.succ.div(2))
         .sort_by { rand }
  end


  class << self
    # リストの状態変化をユーザに通知する
    def notify_players_name(event:, added_names: nil, removed_names: nil, already_added: nil)
      messages =
        [
          BotMessage.added(added_names),
          BotMessage.removed(removed_names),
          BotMessage.already_added(already_added)
        ].compact
         .join("\n")

      event.send_message(messages)
    end

    # Discordrb の event を利用してボイスチャットに参加しているユーザ名一覧を取得する
    def voice_channel_player_names(event:)
      event.user
           .voice_channel
           .users
           .map(&:name)
    end
  end
end
