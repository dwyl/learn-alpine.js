# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     App.Repo.insert!(%App.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias App.Tasks.Person

people = [
  %Person{
    name: "Ines Teles Correia",
    picture: "https://avatars.githubusercontent.com/u/4185328?v=4",
    selected: false
  },
  %Person{
    name: "Nelson Correia",
    picture: "https://avatars.githubusercontent.com/u/194400?v=4",
    selected: false
  },
  %Person{
    name: "Simon Lab",
    picture: "https://avatars.githubusercontent.com/u/6057298?v=4",
    selected: false
  },
  %Person{
    name: "Stephany Rios",
    picture: "https://avatars.githubusercontent.com/u/91985721?v=4",
    selected: false
  },
  %Person{
    name: "Luis Arteiro",
    picture: "https://avatars.githubusercontent.com/u/17494745?v=4",
    selected: false
  },
  %Person{
    name: "Oli Evans",
    picture: "https://avatars.githubusercontent.com/u/58871?v=4",
    selected: false
  },
  %Person{
    name: "Alan Shaw",
    picture: "https://avatars.githubusercontent.com/u/152863?v=4",
    selected: false
  },
  %Person{
    name: "Alex Potsides",
    picture: "https://avatars.githubusercontent.com/u/665810?v=4",
    selected: false
  },
  %Person{
    name: "Amanda Huginkiss",
    picture: "https://avatars.githubusercontent.com/u/5108244?v=4",
    selected: false
  },
  %Person{
    name: "Andrew McAwesome",
    picture: "https://avatars.githubusercontent.com/u/46572910?v=4",
    selected: false
  },
  %Person{
    name: "Emmet Brickowski",
    picture: "https://avatars.githubusercontent.com/u/10835816?v=4",
    selected: false
  },
  %Person{
    name: "Amélie McAwesome",
    picture: "https://avatars.githubusercontent.com/u/22345430?v=4",
    selected: false
  }
]
|> Enum.each(fn p -> App.Repo.insert!(p) end)
