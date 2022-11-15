defmodule App.PersonTest do
  use App.DataCase
  alias App.Tasks.Person

  describe "Test constraints and requirements for Person schema" do
    test "valid person changeset" do
      changeset =
        Person.changeset(%Person{}, %{name: "person1", picture: "pic_url", selected: false})

      assert changeset.valid?
    end

    test "invalid person changeset when name value missing" do
      changeset = Person.changeset(%Person{}, %{person_id: 1, name: ""})
      refute changeset.valid?
    end

    test "invalid person changeset when picture value missing" do
      changeset = Person.changeset(%Person{}, %{name: "person1"})
      refute changeset.valid?
    end
  end
end
