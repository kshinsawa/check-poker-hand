module API
  module V1
    module Cards
      class Check < Grape::API
        resource :cards do
          # rescue_fromは書いた順番にマッチングされる

          # 400 Bad Request
          rescue_from Grape::Exceptions::Base do
            error!(error: "400 Bad Request：不正なリクエストです")
          end

          # 404 Not Found
          route :any, '*path' do
            error!(error: "404 Not Found：指定されたURLは存在しません")
          end

          # 500 Internal Server Error
          rescue_from Exception do
            error!(error: "500 Internal Server Error：予期しないエラーです")
          end

          # POST /api/v1/cards/check
          desc 'Judge hand, strength and best hand'
          params do
            requires :cards, type: Array[String]
          end

          post :check, jbuilder:'cards/check' do
            # Json → Arrayにパースして配列から一つずつeachで取り出して役判定＋強さ判定 → 最終的に強さを比較して最も強いものにbest = trueで返す

            # 配列card_setsを定義する(type: Array(String))
            card_sets = params[:cards]

            # 配列cardsを定義しJudgeServiceをnewして代入する(type: Array(Object))
            @cards = []

            card_sets.each do |card_set|
              @cards.push JudgeService.new(card_set: card_set)
            end

            # 配列cardsの長さ分役判定・強さ判定を実施する

            for card in @cards do
              if card.check_valid_card_set == nil
                card.judge
                card.judge_strength
              else
                next
              end
            end

            # 配列cardsの中で最も強い役の手札にbest: trueをつける
            scores = []

            @cards.each do |card|
              scores.push card.strength.to_i
            end

            high_score =  scores.max

            for i in 0..@cards.length-1 do
              if @cards[i].strength == high_score
                @cards[i].best = true
              else
                @cards[i].best = false
              end
            end
          end
        end
      end
    end
  end
end
