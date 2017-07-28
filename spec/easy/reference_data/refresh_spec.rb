require 'spec_helper'
require 'easy/reference_data/refresh'

RSpec.describe Easy::ReferenceData do

  describe ".update_or_create" do
    context "with a single unique attribute" do
      context "and an existing record" do

        it "does not change the record" do
          user = User.create(system_code: 1)

          expect{ Easy::ReferenceData.update_or_create(User, {system_code: 1}, keys: [:system_code])}.not_to change{ User.count }
        end

        context "with additional attribues" do
          it "updates the existing record" do
            user = User.create(system_code: 1, name: "Jo")

            expect{ Easy::ReferenceData.update_or_create(User, {system_code: 1, name: "Jane"}, keys: [:system_code])}.to change{ user.reload.name }.to "Jane"
          end
        end
      end

      context "and no existing record" do
        it "creates a new record" do
          expect{ Easy::ReferenceData.update_or_create(User, {system_code: 1}, keys: [:system_code])}.to change{ User.count }
        end
      end

    end

    context "with multiple attributes" do
      it "updates the matching record" do
        jo_smith = User.create(system_code: 1, name: "Jo", email: "jo.smith@example.com")
        jo_brown = User.create(system_code: 1, name: "Jo", email: "jo.brown@example.com")

        expect{ Easy::ReferenceData.update_or_create(User, {name: "Jo", email: "jo.brown@example.com", system_code: 2}, keys: [:name, :email])}.to change{ jo_brown.reload.system_code }.to 2
      end

    end
  end

  describe ".refresh" do

    context "with a unique attribue" do
      context "and no exisitng record" do

        it "creates a new record" do
          expect{
            Easy::ReferenceData.refresh User, :system_code, 1, name: "Jane", email: "jane@example.com"
          }.to change{ User.count }
        end

      end

      context "and an exisitng record" do
        it "updates the existing record" do
          user = User.create(system_code: 1, name: "Jo")

          expect{ Easy::ReferenceData.refresh User, :system_code, 1, name: "Jane", email: "jane@example.com" }.to change{ user.reload.name }.to "Jane"
        end

        it "does not create duplicate records" do
          user = User.create(system_code: 1, name: "Jo")

          expect{ Easy::ReferenceData.refresh User, :system_code, 1, name: "Jo", email: "jane@example.com" }.not_to change{ User.count }
        end
      end
    end

  end
end
