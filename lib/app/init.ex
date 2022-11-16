defmodule App.Init do
  alias App.Tasks.Person

  def seeds() do
    [
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
      },
      %Person{
        name: "This is a super long name to check the overflow css property",
        picture: "https://avatars.githubusercontent.com/u/22345430?v=4",
        selected: false
      }
    ]
    |> Enum.each(fn p -> App.Repo.insert!(p) end)
  end
end
