require 'discordrb'
require 'mechanize'
require 'yaml'
require File.join(__dir__, 'lib', 'bot_message')
require File.join(__dir__, 'lib', 'players_list')

# TODO: 実際に動作するか検証する
# FIXME: エラーがあれば修正する

# 飯テロ
def scrape_and_save_food_picture_as(file_name = 'pic.png')
  agent = Mechanize.new
  link = 'https://source.unsplash.com/random/featured/?Food,Plate'
  agent.get(link).save(file_name)
end

# chatbot がコマンドを受けてプレイヤーのリストを管理する
$players = PlayersList.new

#
# Discord chatbot の受け付けコマンドとその振る舞いを設定
#

# chatbot の初期化
discord_chatbot = Discordrb::Commands::CommandBot.new(
  token: ENV['DISCORD_TOKEN'],
  client_id: ENV['DISCORD_CLIENT_ID'],
  prefix: ['/', '\\'],
  command_doesnt_exist_message: BotMessage.command_doesnt_exist
)

# ユーザに挨拶
discord_chatbot.command :hello do |event|
  event.send_message(BotMessage.hello(event.user.name))
end

# ポプ子メッセージ
discord_chatbot.command :hi do |event|
  event.send_file(
    File.open(Dir.glob('img/*').sample, 'r'),
    caption: "#{event.user.name} !!!"
  )
end

# Food 写真提供
discord_chatbot.command :food do |event|
  file_name = 'pic.png'
  scrape_and_save_food_picture_as(file_name)

  event.send_file(File.open(file_name, 'r'), caption: "OK, #{event.user.name} .")

  sleep(3)

  File.delete(file_name)
end

# 参加者追加コマンド
discord_chatbot.command [:add, :addme] do |event, *code|
  # 引数無しなら発言した本人のユーザ名を使う
  player_names = (code[0] ? code : [event.user.name])

  matched, unmatched =
    $players.filter_matched_or_not(player_names)

  messages =
    BotMessage.build_players_name_list(
      event: event,
      added_names: matched,
      already_added: unmatched
    )

  event.send_message(messages)

end

# 発言者の居るボイスチャンネルのメンバーを全員参加者リストに追加
discord_chatbot.command :addall do |event|
  if event.user.voice_channel.nil?
    event.send_message(BotMessage.no_voice_channel_members)
    return
  end

  voice_channel_player_names =
    PlayersList.voice_channel_player_names(event: event)

  matched, unmatched =
    $players.filter_matched_or_not(voice_channel_player_names)

  $players.insert_new_players(voice_channel_player_names)

  messages =
    BotMessage.build_players_name_list(
      added_names: matched,
      already_added: unmatched
    )

  event.send_message(messages)

end

# 参加者削除コマンド
discord_chatbot.command [:remove, :rm, :removeme, :rmme] do |event, *code|
  # 引数無しならユーザ名
  player_names = (code[0] ? code : [event.user.name])

  matched, unmatched =
    $players.filter_matched_or_not(player_names, to_remove: true)

  $players.remove_players_from_list(player_names)

  messages =
    BotMessage.build_players_name_list(
      removed_names: matched,
      already_added: unmatched
    )

  event.send_message(messages)
end

# 参加者一覧をリストアップ
discord_chatbot.command [:list, :ls] do |event, *code|
  messages =
    if $players.list.empty?
      BotMessage.no_players
    else
      BotMessage.players_list($players.list)
    end

  event.send_message(messages)
end

# 参加者リスト初期化
discord_chatbot.command [:clear, :clr, :removeall, :rmall] do |event|
  $players.clear_list!
  event.send_message(BotMessage.initialized)
end

# 各プレイヤーをチームに分ける
discord_chatbot.command [:grouping, :group, :gp] do |event|
  if $players.no_players?
    event.send_message(BotMessage.need_two_or_more_players)
    return
  end

  event.send_message(
    BotMessage.tagged_team_list(
      $players.divide_to_two_teams
    )
  )
end

# 一発で発言者の居るボイスチャンネルメンバー全員のチーム分け
discord_chatbot.command [:r6s, :r6] do |event|
  if event.user.voice_channel.nil?
    event.send_message(BotMessage.no_voice_channel_members)
    return
  end

  if $players.no_players?
    event.send_message(BotMessage.need_two_or_more_players)
    return
  end

  messages = $players.make_two_teams_by_voice_chat_players

  event.send_message(
    BotMessage.tagged_team_list(
      messages
    )
  )
end

# YAML ファイルに設定したステージ情報をもとにランダム指定
discord_chatbot.command :stage do |event, *code|
  # 変数
  choice_list = YAML.load_file('config/config.yml')['stage']
  map_list    = YAML.load_file('config/stage.yml')['stage'][choice_map]
  choice_map  = code[0]
  # 確認
  event.send_message(BotMessage.choice_map(choice_map))
  # 分岐
  if choice_list.include?(choice_map)
    event.send_message(BotMessage.map_list(map_list.sample))
  else
    event.send_message(BotMessage.command_doesnt_exist)
  end
end

# 追加した振る舞いを持ち併せた状態で動作開始
discord_chatbot.run
