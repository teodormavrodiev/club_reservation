require 'faker'

User.destroy_all
Club.destroy_all



user1 = User.new({
  full_name: Faker::Name.name,
  password: "password",
  password_confirmation: "password",
  email: "teodor.test@gmail.com",
  phone_number: "+359881421314131231"
  })

user1.save!

user2 = User.new({
  full_name: Faker::Name.name,
  password: "password",
  password_confirmation: "password",
  email: "teodor.test2@gmail.com",
  phone_number: "+3598814213141312311"
  })

user2.save!

club = Club.new({
  name: "Club 33",
  capacity: 260,
  location: "street atanas manchev, 1700, Sofia, Bulgaria",
  description: "Awesome club in the heart of party town.",
  region: "Studentski Grad"
  })

club2 = Club.new({
  name: "Mascara",
  capacity: 300,
  location: "rakovska 25, Sofia, Bulgaria",
  description: "Awesome club in the heart of the city.",
  region: "Centura"
  })

club.club_owner = user1
club2.club_owner = user2

club.save!
club2.save!

club.photo_urls = ["http://res.cloudinary.com/teodormavrodiev/image/upload/v1497112699/6_fekr3p.jpg",
"http://res.cloudinary.com/teodormavrodiev/image/upload/v1497112698/5_dd6wg7.jpg",
"http://res.cloudinary.com/teodormavrodiev/image/upload/v1497112699/4_o7i2vh.jpg",
"http://res.cloudinary.com/teodormavrodiev/image/upload/v1497112698/3_dadnzo.jpg",
"http://res.cloudinary.com/teodormavrodiev/image/upload/v1497112698/2_xb10kz.jpg"]


club2.photo_urls = ["http://res.cloudinary.com/teodormavrodiev/image/upload/v1497112699/6_fekr3p.jpg",
"http://res.cloudinary.com/teodormavrodiev/image/upload/v1497112698/5_dd6wg7.jpg",
"http://res.cloudinary.com/teodormavrodiev/image/upload/v1497112699/4_o7i2vh.jpg"]

6.times { |i|
  table = Table.new({
    capacity: 15,
    kaparo_required: true,
    kaparo_amount: 300
    })
  table.club = club
  table.save!
}

6.times { |i|
  table = Table.new({
    capacity: 15,
    kaparo_required: false
    })
  table.club = club2
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
    date: Date.today,
    kaparo_paid: true
    })
  reservation.reservation_owner = user1 if i == 0
  reservation.reservation_owner = user2 if i == 1
  reservation.tables = [Table.first, Table.second] if i ==0
  reservation.tables = [Table.third] if i == 1
  reservation.participants = [User.second] if i == 0
  reservation.participants = [User.first] if i == 1
  reservation.save!
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
