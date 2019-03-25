# TODO: 実際に動作するか検証する
# TODO: テストコードを追加する
# FIXME: エラーがあれば修正する

require 'active_support/core_ext/object/blank'

# Discord bot に喋らせるセリフ集
class BotMessage
  class << self
    def command_doesnt_exist
      'そんなコマンドはないよ'
    end

    def hello(name)
      "hello, world! #{name}"
    end

    def added(names)
      "`#{names.join('`, `')}`を追加しました。" if names.present?
    end

    def already_added(names)
      "`#{names.join('`, `')}`は既に参加済み。" if names.present?
    end

    def removed(names)
      "`#{names.join('`, `')}`をリストから削除しました。" if names.present?
    end

    def no_members(names)
      "`#{names.join('`, `')}`はおらんで。" if names.present?
    end

    def no_players
      '誰もリストにはおらんよ'
    end

    def initialized
      '初期化完了。'
    end

    def player_list(player_list)
      "```\n#{player_list.join("\n")}\n```"
    end

    def need_two_or_more_players
      '二人以上の参加者が必要です...'
    end

    def tagged_team_list(team_list)
      <<EOS
__**【BlueTeam】**__
```
#{team_list[0].join("\n")}
```
__**【OrangeTeam】**__
```
#{team_list[1].join("\n")}
```
Good Luck, Have Fun!
EOS
    end

    def no_voice_channel_members
      "発言者の居るボイスチャンネルのメンバーを追加するコマンドです。\nどこかのボイスチャンネルに入って使用してください。"
    end

    def choice_map(choice_map)
      "\nChoise #{choice_map}\n"
    end

    def map_list(map)
      "```\n #{map}\n```"
    end
  end
end
