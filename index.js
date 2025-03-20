exports.handler = async (event) => {
    try {
        // Get current time in Paris (Europe/Paris timezone)
        const parisTime = new Date().toLocaleString('fr-FR', {
            timeZone: 'Europe/Paris',
            dateStyle: 'full',
            timeStyle: 'long'
        });
        
        // Name information
        const firstName = 'Sven';
        const lastName = 'Tual';
        
        // Prepare response
        const response = {
            statusCode: 200,
            body: JSON.stringify({
                message: `Bonjour ${firstName} ${lastName}. Il est ${parisTime}`,
                currentTime: parisTime,
                timezone: 'Europe/Paris',
                name: {
                    firstName: firstName,
                    lastName: lastName
                }
            })
        };
        
        return response;
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({
                message: 'Une erreur est survenue',
                error: error.message
            })
        };
    }
};
