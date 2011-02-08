module DeviseActiveDirectoryAuthenticatable

  class Logger    
    def self.send(message, logger = Rails.logger)
      if ::Devise.ad_logger
        logger.add 0, "  \e[36mActiveDirectory:\e[0m #{message}"
      end
    end
  end

end
