/*
 * Copyright (c) 2000-2012, GPGTools Project Team <gpgtools-devel@lists.gpgtools.org>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of GPGTools Project Team nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY GPGTools Project Team AND CONTRIBUTORS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL GPGTools Project Team AND CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Libmacgpg/Libmacgpg.h>
#import "CCLog.h"
#import "MCMutableMessageHeaders.h"
#import "NSString+GPGMail.h"
#import "Message+GPGMail.h"
#import "GMSecurityHistory.h"

#import "GMMessageSecurityFeatures.h"

#import "MCMessage.h"
#import "MCMessageHeaders.h"

@implementation GMSecurityHistory

+ (GPGMAIL_SECURITY_METHOD)defaultSecurityMethod {
	GPGMAIL_SECURITY_METHOD securityMethod = (GPGMAIL_SECURITY_METHOD)[[GPGOptions sharedOptions] integerForKey:@"DefaultSecurityMethod"];
	if (securityMethod < 1 || securityMethod > 2) {
		securityMethod = GPGMAIL_SECURITY_METHOD_OPENPGP;
	}
	DebugLog(@"Default Security Method is: %@", securityMethod == GPGMAIL_SECURITY_METHOD_SMIME ? @"S/MIME" : @"OpenPGP");
    return securityMethod;
}

- (GMSecurityOptions *)securityOptionsFromDefaults {
	GPGOptions *options = [GPGOptions sharedOptions];
	BOOL sign = [options boolForKey:@"SignNewEmailsByDefault"];
	BOOL encrypt = [options boolForKey:@"EncryptNewEmailsByDefault"];
	GPGMAIL_SECURITY_METHOD securityMethod = [[self class] defaultSecurityMethod];

	return [GMSecurityOptions securityOptionsWithSecurityMethod:securityMethod
													 shouldSign:sign
												  shouldEncrypt:encrypt];
}

- (GMSecurityOptions *)bestSecurityOptionsForSignFlags:(GPGMAIL_SIGN_FLAG)signFlags
                                          encryptFlags:(GPGMAIL_ENCRYPT_FLAG)encryptFlags {
	
	GMSecurityOptions *defaultSecurityOptions = [self securityOptionsFromDefaults];
	
	BOOL canPGPSign = (signFlags & GPGMAIL_SIGN_FLAG_OPENPGP) == GPGMAIL_SIGN_FLAG_OPENPGP;
    BOOL canPGPEncrypt = (encryptFlags & GPGMAIL_ENCRYPT_FLAG_OPENPGP)  == GPGMAIL_ENCRYPT_FLAG_OPENPGP;
    BOOL canSMIMESign = (signFlags & GPGMAIL_SIGN_FLAG_SMIME) == GPGMAIL_SIGN_FLAG_SMIME;
    BOOL canSMIMEEncrypt = (encryptFlags & GPGMAIL_ENCRYPT_FLAG_SMIME) == GPGMAIL_ENCRYPT_FLAG_SMIME;
    BOOL SMIMEKeyAvailable = canSMIMESign || canSMIMEEncrypt;
    BOOL PGPKeyAvailable = canPGPSign || canPGPEncrypt;
	
	GPGMAIL_SECURITY_METHOD securityMethod = defaultSecurityOptions.securityMethod;
	
	// Select the security method based on the availability of keys.
    if(SMIMEKeyAvailable && !PGPKeyAvailable) {
        securityMethod = GPGMAIL_SECURITY_METHOD_SMIME;
    }
    else if(PGPKeyAvailable && !SMIMEKeyAvailable) {
		securityMethod = GPGMAIL_SECURITY_METHOD_OPENPGP;
    }

	GMSecurityOptions *finalSecurityOptions = [GMSecurityOptions securityOptionsWithSecurityMethod:securityMethod shouldSign:defaultSecurityOptions.shouldSign shouldEncrypt:defaultSecurityOptions.shouldEncrypt];
	
	return finalSecurityOptions;
}

- (GMSecurityOptions *)bestSecurityOptionsForReplyToMessage:(Message_GPGMail *)message signFlags:(GPGMAIL_SIGN_FLAG)signFlags
                                               encryptFlags:(GPGMAIL_ENCRYPT_FLAG)encryptFlags {
    
    GMSecurityOptions *defaultSecurityOptions = [self securityOptionsFromDefaults];
    // Bug #953: Wrong security method is selected for replies if keys for both methods are available.
    //
    // If a reply is composed and keys are available for either security methods, it's possible
    // that the returned security method remains OPENPGP_SECURITY_METHOD_UNKNOWN.
    // To fix that, securityMethod is initially set to the default.
    GPGMAIL_SECURITY_METHOD securityMethod = defaultSecurityOptions.securityMethod;
    BOOL canPGPSign = (signFlags & GPGMAIL_SIGN_FLAG_OPENPGP) == GPGMAIL_SIGN_FLAG_OPENPGP;
    BOOL canPGPEncrypt = (encryptFlags & GPGMAIL_ENCRYPT_FLAG_OPENPGP) == GPGMAIL_ENCRYPT_FLAG_OPENPGP;
    BOOL canSMIMESign = (signFlags & GPGMAIL_SIGN_FLAG_SMIME) == GPGMAIL_SIGN_FLAG_SMIME;
    BOOL canSMIMEEncrypt = (encryptFlags & GPGMAIL_ENCRYPT_FLAG_SMIME) == GPGMAIL_ENCRYPT_FLAG_SMIME;
    BOOL canSign = NO;
    BOOL canEncrypt = NO;
    BOOL SMIMEKeyAvailable = canSMIMESign || canSMIMEEncrypt;
    BOOL PGPKeyAvailable = canPGPSign || canPGPEncrypt;
    GMMessageSecurityFeatures *securityFeatures = [message securityFeatures];
    BOOL messageIsSigned = securityFeatures.PGPSigned || message.isSMIMESigned;
    BOOL messageIsEncrypted = securityFeatures.PGPEncrypted || message.isSMIMEEncrypted;

    // Message is not signed, check the defaults on what to do.
    if(!messageIsSigned && (canPGPSign || canSMIMESign)) {
        canSign = defaultSecurityOptions.shouldSign;
        securityMethod = canPGPSign && canSMIMESign ? defaultSecurityOptions.securityMethod : (canPGPSign ? GPGMAIL_SECURITY_METHOD_OPENPGP : GPGMAIL_SECURITY_METHOD_SMIME);
    }
    if(!messageIsEncrypted && (canPGPEncrypt || canSMIMEEncrypt)) {
        canEncrypt = defaultSecurityOptions.shouldEncrypt;
        securityMethod = canPGPSign && canSMIMESign ? defaultSecurityOptions.securityMethod : (canPGPSign ? GPGMAIL_SECURITY_METHOD_OPENPGP : GPGMAIL_SECURITY_METHOD_SMIME);
    }

    // If there's a signing key, and the message was signed, enable signing.
    if(messageIsSigned && (canSMIMESign || canPGPSign))
        canSign = YES;

    // If there's a encryption key and the message was encrypted, enable encrypting.
    if(messageIsEncrypted && (canSMIMEEncrypt || canPGPEncrypt))
        canEncrypt = YES;

    // Keys for both methods are available
    if(SMIMEKeyAvailable && PGPKeyAvailable) {
        if(message.isSMIMESigned || message.isSMIMEEncrypted)
            securityMethod = GPGMAIL_SECURITY_METHOD_SMIME;
        else if(securityFeatures.PGPSigned || securityFeatures.PGPEncrypted)
            securityMethod = GPGMAIL_SECURITY_METHOD_OPENPGP;
        // Not signed or not encrypted is already handled above.
    }
    else if(SMIMEKeyAvailable && !PGPKeyAvailable)
        securityMethod = GPGMAIL_SECURITY_METHOD_SMIME;
    else if(PGPKeyAvailable && !SMIMEKeyAvailable)
        securityMethod = GPGMAIL_SECURITY_METHOD_OPENPGP;
    
    return [GMSecurityOptions securityOptionsWithSecurityMethod:securityMethod shouldSign:canSign shouldEncrypt:canEncrypt];
}

@end

@implementation GMSecurityOptions

@synthesize securityMethod = _securityMethod, shouldSign = _shouldSign, shouldEncrypt = _shouldEncrypt;

- (id)initWithSecurityMethod:(GPGMAIL_SECURITY_METHOD)securityMethod shouldSign:(BOOL)shouldSign shouldEncrypt:(BOOL)shouldEncrypt {
    if(self = [super init]) {
        _securityMethod = securityMethod;
        _shouldSign = shouldSign;
        _shouldEncrypt = shouldEncrypt;
    }
    return self;
}

+ (GMSecurityOptions *)securityOptionsWithSecurityMethod:(GPGMAIL_SECURITY_METHOD)securityMethod shouldSign:(BOOL)shouldSign shouldEncrypt:(BOOL)shouldEncrypt {
    GMSecurityOptions *securityOptions = [[GMSecurityOptions alloc] initWithSecurityMethod:securityMethod shouldSign:shouldSign shouldEncrypt:shouldEncrypt];
    return securityOptions;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Best Security options: {\n\tSecurity Method: %@\n\tShould Sign: %@\n\tShould Encrypt: %@\n}", 
            self.securityMethod == GPGMAIL_SECURITY_METHOD_OPENPGP ? @"OpenPGP" : @"S/MIME",
            self.shouldSign ? @"YES" : @"NO", self.shouldEncrypt ? @"YES" : @"NO"];
}

@end
