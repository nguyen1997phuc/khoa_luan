class DocumentsController < ApplicationController
  before_action :load_document, only: %i(show update destroy edit)
  impressionist :actions => [:show]

  def new
    @document = Document.new
  end
  
  def index
    @documents = @q.result.page(params[:page]).per(10)
  end
  
  def show
    category_id = @document.category_id
    @relation_documents = Document.where(category_id: category_id).limit(10)
    impressionist(@document)
  end

  def create
    @document = Document.new document_params
    if @document.save
      redirect_to @document
      flash[:success] = "Bạn đã đăng tải tài liệu thành công"
      UserUploadDocument.create(user_id: current_user.id, document_id: Document.last.id)
      if feature_user_document_params.present?
        feature_params = feature_user_document_params.merge(document_id: @document.id)
        FeatureUserDocument.create feature_params
      end
      if feature_categories_document_params.present?
        feature_params = feature_categories_document_params.merge(document_id: @document.id)
        FeatureCategoriesDocument.create feature_params
      end
    else
      flash[:error] = "Đăng tải tài liệu thất bại"
      render :new
    end
  end

  def update
    feature_user_document = FeatureUserDocument.find_by(document_id: @document.id)
    if @document.update(document_params) && feature_user_document.update(feature_user_document_params)
      flash[:success] = "Bạn đã update thông tin tài liệu thành công"
      redirect_to @document
    else
      flash[:error] = "Update tài liệu thất bại"
      render :edit
    end
  end

  def edit
    @feature_user_document = FeatureUserDocument.find_by(document_id: @document.id)
    @feature_categories_document = FeatureCategoriesDocument.find_by(document_id: @document.id)
  end

  def destroy
    uploader = UserUploadDocument.find_by(user_id: current_user, document_id: @document.id)
    uploader.destroy
    @document.destroy
    flash[:error] = "Bạn đã xóa tài liệu thành công"
    redirect_to user_upload_documents_path 
  end

  private

  def load_document
    @document = Document.find_by id: params[:id]
  end

  def document_params
    params.require(:document).permit(:category_id, :source_file,
      :image, :name, :author_name, :language_id, :description
    )
  end

  def feature_user_document_params
    params.require(:document).permit(:gender, :generation, :status)
  end

  def feature_categories_document_params
    params.require(:document).permit(main_major: [])
  end
end
