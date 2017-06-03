require 'faker'

User.destroy_all
Reservation.destroy_all
Partygoer.destroy_all
Club.destroy_all
Comment.destroy_all
Rating.destroy_all


user1 = User.new({
  full_name: Faker::Name.name,
  password: "password",
  password_confirmation: "password",
  email: "teodor.test@gmail.com"
  })

user1.save!

user2 = User.new({
  full_name: Faker::Name.name,
  password: "password",
  password_confirmation: "password",
  email: "teodor.test2@gmail.com"
  })

user2.save!

club = Club.new({
  name: "Club 33"
  })

club.club_owner = user1

club.save!

3.times { |i|
  table = Table.new({
    capacity: 15
    })
  table.club = club
  table.save!
}

2.times { |i|
  rating = Rating.new({
    information: Faker::Hipster.paragraph,
    score: 5
    })
  rating.user = User.first if i == 0
  rating.user = User.second if i == 1
  rating.club = club
  rating.save!
}

2.times { |i|
  reservation = Reservation.new({
    capacity: 15,
    date: Date.today
    })
  reservation.reservation_owner = user1 if i == 0
  reservation.reservation_owner = user2 if i == 1
  reservation.table = Table.first if i == 0
  reservation.table = Table.second if i == 1
  reservation.save!
}

2.times { |i|
  partygoer = Partygoer.new
  partygoer.participant = user1 if i == 0
  partygoer.participant = user2 if i == 1
  partygoer.reservation = Reservation.first if i == 1
  partygoer.reservation = Reservation.second if i == 0
  partygoer.save!
}

2.times { |i|
  comment = Comment.new({
    information: Faker::Hipster.paragraph,
    datetime: DateTime.now
    })
  comment.user = user1 if i == 0
  comment.user = user2 if i == 1
  comment.reservation = Reservation.first if i == 1
  comment.reservation = Reservation.second if i == 0
  comment.save!
}
