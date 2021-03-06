class Model
	include HTTParty
  	format :json
  	base_uri BASE_URI + '/models'

  	attr_accessor :modelID, :modelStatus, :pngUrl, :zipUrl, :thumbUrl, :threshold, :level, :license, :citation, :methodFile, :published

  	def initialize(modelID, modelStatus, pngUrl, zipUrl, thumbUrl, threshold, level, license, citation, methodFile, published)
  		self.modelID = modelID
      self.modelStatus = modelStatus
	    self.pngUrl = pngUrl
      self.zipUrl = zipUrl
	    self.thumbUrl = thumbUrl
	    self.threshold = threshold
      self.level = level
      self.license = license   
      self.citation = citation
      self.methodFile = methodFile
      self.published = published
  	end

    # Gets an array of thresholds of the species continuous model developed by BioModelos via API.  
    #
    # @param species_id [Number] ID of the species.
    # @return [Array] Thresholds models objects.
    def self.get_thresholds(species_id)
      response = JSON.parse(get('/' + species_id + '?type=Thresholds').body)
      thresholds_array = []
      response.each do |threshold|
        t = Model.new(threshold["modelID"], threshold["modelStatus"], threshold["png"], threshold["zip"], threshold["thumb"], threshold["thresholdType"], threshold["modelLevel"], threshold["license"], threshold["customCitation"], threshold["methodFile"], threshold["published"])
        thresholds_array.push(t)
      end
      return thresholds_array
    end

    # Gets an array of a species models pending of validation via API.  
    #
    # @param species_id [Number] ID of the species.
    # @return [Array] Model objects pending of validation.
  	def self.get_hypotheses(species_id)
  		response = JSON.parse(get('/' + species_id + '?type=Hypothesis').body)
  		hypotheses_array = []
    	response.each do |hypothesis|
    		t = Model.new(hypothesis["modelID"], hypothesis["modelStatus"], hypothesis["png"], hypothesis["zip"], hypothesis["thumb"], hypothesis["thresholdType"], hypothesis["modelLevel"], hypothesis["license"], hypothesis["customCitation"], hypothesis["methodFile"], hypothesis["published"])
    		hypotheses_array.push(t)
      end
		  return hypotheses_array
  	end

    # Gets a species continuous model developed by BioModelos via API.  
    #
    # @param species_id [Number] ID of the species.
    # @return [Object] Continuous model object.
    def self.get_continous_model(species_id)
      response = JSON.parse(get('/' + species_id + '?type=Continuous').body)
      if response.size > 0
        continuous_model = Model.new(response[0]["modelID"], response[0]["modelStatus"], response[0]["png"], response[0]["zip"], response[0]["thumb"], response[0]["thresholdType"], response[0]["modelLevel"], response[0]["license"], response[0]["customCitation"], response[0]["methodFile"], response[0]["published"])
      else
        continuous_model = nil
      end

      return continuous_model
    end

    # Gets a species validated model via API.  
    #
    # @param species_id [Number] ID of the species.
    # @return [Object] Valid model object.
    def self.get_valid_model(species_id)
      response = JSON.parse(get('/' + species_id + '?type=Valid').body)
      if response.size > 0
        valid_model = Model.new(response[0]["modelID"], response[0]["modelStatus"], response[0]["png"], response[0]["zip"], response[0]["thumb"], response[0]["thresholdType"], response[0]["modelLevel"], response[0]["license"], response[0]["customCitation"], response[0]["methodFile"], response[0]["published"])
      else
        valid_model = nil
      end
      return valid_model
    end

    def self.eoo(species_id)
      JSON.parse(get('/approved/eoo/' + species_id).body)
    end

    def self.rpa(species_id)
      JSON.parse(get('/approved/rpa/' + species_id).body)
    end

    def self.forest_loss(species_id)
      JSON.parse(get('/approved/forest_loss/' + species_id).body)
    end

    def self.covers(species_id)
      JSON.parse(get('/approved/covers/' + species_id).body)
    end

    def self.get_metadata(model_id)
      JSON.parse(get('/metadata/' + model_id.to_s).body)
    end

    # Gets the best model hypothesis based on rating.  
    #
    # @param hypotheses [Array] Array of Model objects.
    # @return [Object] Best hypothesis Model object.
    def self.get_best_hypothesis(hypotheses)
      best_hypothesis = nil
      best_rating = -1
      actual_rating = 0
      hypotheses.each do |hypothesis| 
        actual_rating = Rating.average_rating(hypothesis.modelID)
        if actual_rating > best_rating
          best_hypothesis = hypothesis
          best_rating = actual_rating
        end
      end
      return best_hypothesis
    end

    def self.models_stats
      JSON.parse(get('/stats').body)
    end

    def self.valid_records_number(taxID)
      values = JSON.parse(get('/approved/eoo/' + taxID.to_s).body)
      rec_number = values.blank? ? "-" : values[0]["recsUsed"]
      return rec_number
    end
end