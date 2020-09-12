class Pay < ApplicationRecord
    
    belongs_to :card
    belongs_to :reserve
    
end
