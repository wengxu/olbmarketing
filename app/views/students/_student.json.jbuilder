json.extract! student, :id, :first_name, :last_name, :school_year, :new_or_return, :student_class, :catholic, :parish, :race, :resides_with, :reference_from, :student_transfer, :preK_to_K, :father_name, :mother_name, :address, :city, :state, :zip, :email1, :email2, :note, :created_at, :updated_at
json.url student_url(student, format: :json)