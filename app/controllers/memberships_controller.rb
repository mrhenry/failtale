class MembershipsController < ApplicationController
  
  before_filter :require_user
  before_filter :require_project_ownership, :only => [:new, :create]
  before_filter :require_project_ownership_or_membership, :only => [:destroy]
  
  def new
    @membership = project.memberships.build
  end
  
  def create
    @membership = project.memberships.build(params[:membership])
    @membership.save!
    
    respond_to do |format|
      format.html { redirect_to project }
      format.xml  { render :xml  => @membership, :status => :created }
      format.json { render :json => @membership, :status => :created }
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.html { render :action => 'new' }
      format.xml  { render :xml  => e.record.errors, :status => :unprocessable_entity }
      format.json { render :json => e.record.errors, :status => :unprocessable_entity }
    end
  end
  
  def destroy
    membership.destroy
    redirect_to project
  end
  
  private
  
  def project
    @project ||= current_user.projects.find(params[:project_id])
  end
  
  def membership
    @membership ||= current_user.memberships.first(:conditions => { :project_id => project.id})
  end
  
  def ownership?
    current_user.id == project.owner_id
  end
  
  def membership?
    !project.nil?
  end
  
  def require_project_ownership
    unless ownership?
      store_location
      flash[:notice] = "You must be the owner of this project"
      redirect_to home_path
      return false
    end
  end
  
  def require_project_ownership_or_membership
    unless ownership? or membership?
      store_location
      flash[:notice] = "You must be the owner of this project"
      redirect_to home_path
      return false
    end
  end
  
end