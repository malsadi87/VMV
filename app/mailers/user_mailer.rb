class UserMailer < ApplicationMailer
    helper :application
    default from: Rails.application.credentials.surrey[:address]  
    def welcome_email(receiver)
      puts "the mail will be sent to "
      puts receiver
      mail(to: receiver, subject: 'VMV: Login Credential')
    end
  
    def blockchain_email(receiver)
      puts "the mail will be sent to "
      puts receiver
      mail(to: receiver, subject: 'Vote Record')
    end
  
    def verification_email(receiver)
      puts "the mail will be sent to "
      puts receiver
      mail(to: receiver, subject: 'Vote Verification')
    end
end
