# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  category   :string
#  prof_pic   :string
#  username   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_accounts_on_user_id  (user_id)
#

class Account < ApplicationRecord
end
