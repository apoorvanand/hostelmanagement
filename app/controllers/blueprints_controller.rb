# frozen_string_literal: true

class BlueprintsController < ApplicationController
  prepend_before_action :set_blueprint, except: %i(new create 
                                                   index import)

  def new
    @blueprint = Blueprint.new
  end

  def index
    @blueprints = Blueprint.all
  end

  def show; end

  def create
    result = Creator.create!(params: blueprint_params, klass: Blueprint,
                                 name_method: :blueprint_name)
    @blueprint = result[:record]
    handle_action(action: 'new', **result)
  end

  def destroy
    result = Destroyer.new(object: @blueprint, 
                           name_method: :blueprint_name).destroy
    # handle_action()
  end

  # Probably turn this into a service object
  def import
    Suite.all.each do |suite|
      params = import_suite suite
      result = Creator.create!(params: params, klass: Blueprint,
                               name_method: :blueprint_name)
    end
    # handle_action()
  end

  private

  def authorize!
    if @blueprint
      authorize @blueprint
    else
      authorize Blueprint
    end
  end

  def import_suite(suite)
    {
      building: suite.building.name,
      name: suite.name,
      size: suite.size,
      rooms: suite.rooms.map { |room| 
        room.number
      }
    }
  end

  def set_blueprint 
    @blueprint = Blueprint.find(params[:id])
  end

  def blueprint_params 
    params.require(:blueprint).permit(:building, :name, :size, :rooms)
  end

end
