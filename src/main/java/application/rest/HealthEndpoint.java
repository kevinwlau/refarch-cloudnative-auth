package application.rest;

import javax.enterprise.context.ApplicationScoped;

import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.Liveness;

@Liveness
@ApplicationScoped
public class HealthEndpoint implements HealthCheck {

	@Override
	public HealthCheckResponse call() {
		// TODO Auto-generated method stub
		return HealthCheckResponse.named("AuthService").withData("Auth Service", "UP").up().build();
	}

}
