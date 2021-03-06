class StudentsController < ApplicationController
  before_filter :authorize
  before_action :set_student, only: [:show, :edit, :update, :destroy]

  @@valid_column_names = ["first_name", "last_name", "school_year", "new_or_return", "student_class", "catholic", "parish", "race", "resides_with", "reference_from", "student_transfer", "preK_to_K", "father_name", "mother_name", "address", "city", "state", "zip", "email1", "email2", "note", "alumni", "reason", "K_First", "address2", "city2", "state2", "zip2", "phone1", "phone2"]

  # GET /students
  # GET /students.json
  def index
    @students = Student.all
  end

  # GET /students/1
  # GET /students/1.json
  def show
  end

  # GET /students/new
  def new
    @student = Student.new
  end

  # GET /students/1/edit
  def edit
  end

  # POST /students
  # POST /students.json
  def create
    @student = Student.new(student_params)

    respond_to do |format|
      if @student.save
        format.html { redirect_to '/students', notice: 'Student was successfully created.' }
        format.json { render :show, status: :created, location: @student }
      else
        format.html { render :new }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /students/1
  # PATCH/PUT /students/1.json
  def update
    respond_to do |format|
      if @student.update(student_params)
        format.html { redirect_to @student, notice: 'Student was successfully updated.' }
        format.json { render :show, status: :ok, location: @student }
      else
        format.html { render :edit }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students/1
  # DELETE /students/1.json
  def destroy
    @student.destroy
    respond_to do |format|
      format.html { redirect_to students_url, notice: 'Student was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def import
    my_csv = Student.get_csv_from_file params[:file]
    # process csv to remove unidentified columns 
    removed_columns = remove_extra_columns_for_csv my_csv
    remove_column_rows my_csv
    students_from_file = Student.get_students_from_csv my_csv
    
    all_valid = true 
    @upload_errors = []
    # check for errors before insert data 
    students_from_file.each_with_index do |s, index|
      all_valid = false if s.invalid?
      s.errors.full_messages.each do |e|
        @upload_errors << "At row #{index + 2}: #{e}"
      end 
    end 
    # insert data into db if all data valid 
    if all_valid 
      students_from_file.each{|s| s.save}
    end 
    respond_to do |format|
      if all_valid
        format.html { redirect_to students_url, notice: "Data imported! #{"Unidentified columns : " + removed_columns.to_s if removed_columns.count > 0}" }
      else
        @students = Student.all
        format.html { render :index }
        format.json { render json: @upload_errors, status: :unprocessable_entity }
      end
    end 
    
  end 

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.require(:student).permit(:first_name, :last_name, :school_year, :new_or_return, :student_class, :catholic, :parish, :race, :resides_with, :reference_from, :student_transfer, :preK_to_K, :father_name, :mother_name, :address, :city, :state, :zip, :email1, :email2, :note, :alumni, :reason, :K_First, :address2, :city2, :state2, :zip2, :phone1, :phone2)
    end

    def remove_extra_columns_for_csv(my_csv)
      removed_columns = []
      my_csv.headers.each do |h|
        if !(@@valid_column_names.include? h)
          my_csv.delete h
          removed_columns << h
        end 
      end 
      removed_columns
    end

    # remove rows if the row has 'columnX' as content 
    def remove_column_rows(my_csv)
      my_csv.delete_if do |row|
        result = false 
        # check only first 3 columns   
        if row.headers.count >= 3
          result = true if row.field(0) =~ /\Acolumn.*\z/i && row.field(1) =~ /\Acolumn.*\z/i && row.field(2) =~ /\Acolumn.*\z/i
        end 
        result
      end 
    end 
end
