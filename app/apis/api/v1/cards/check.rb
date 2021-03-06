module API
  module V1
    module Cards
      class Check < Grape::API
        resource :cards do
          # POST /api/v1/cards/check
          desc 'Judge hand, strength and best hand'
          params do
            requires :cards, type: Array[String]
          end

          post :check, jbuilder:'cards/check' do
            # 配列card_setsを定義しparamsを代入する(type: Array(String))
            card_sets = params[:cards]

            # 配列cardsを定義しJudgeServiceをnewして代入する(type: Array(Object))
            @cards = []

            card_sets.each do |card_set|
              @cards.push JudgeService.new(card_set: card_set)
            end

            # 配列cardsの長さ分役判定・強さ判定を実施する
            for card in @cards do
              if card.check_valid_card_set == nil
                card.judge_strength
              else
                next
              end
            end

            # 配列cardsの中で最も強い役の手札にbest: trueをつける
            JudgeService.judge_strongest(@cards)
          end
        end
      end
    end
  end
end
