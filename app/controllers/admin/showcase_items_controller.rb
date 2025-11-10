class Admin::ShowcaseItemsController < ApplicationController
  
  def index
    @showcase_items = ShowcaseItem.all.order(active: :desc).order(:sort_order)

    add_breadcrumb 'Showcase'
  end

  def new
    @item = ShowcaseItem.new

    add_breadcrumb 'Showcase', :admin_showcase_items_path
    add_breadcrumb 'Add Item'
  end

  def create
    @item = ShowcaseItem.new(item_params)
    
    if @item.save
      redirect_to admin_showcase_items_path, flash: { success: 'Item added successfully' }
    else
      render action: 'new'
    end
  end

  def edit
    @item = ShowcaseItem.find(params[:id])

    add_breadcrumb 'Showcase', :admin_showcase_items_path
    add_breadcrumb 'Edit Item'
  end

  def update
    @item = ShowcaseItem.find(params[:id])

    if @item.update(item_params)
      redirect_to admin_showcase_items_path(), flash: { success: 'Item updated successfully' }
    else
      render 'edit'
    end
  end

  def destroy
    @item = ShowcaseItem.find(params[:id])
    if @item.destroy
      redirect_to admin_showcase_items_path, flash: { success: 'Item removed successfully' }
    else
      redirect_to admin_showcase_items_path, flash: { error: 'Unable to remove item' }
    end
  end

  private
    def item_params
      params.require(:showcase_item).permit(:name, :title, :caption, :url, :active, :showcase_image, :sort_order, :alt_text)
    end
end