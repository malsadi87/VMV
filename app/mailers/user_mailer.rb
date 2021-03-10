class UserMailer < ApplicationMailer
    helper :application
    default from: "voteverify20@gmail.com"
    #Rails.application.credentials.gmail[:user_name]
  
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
