package application.rest;

import java.util.ArrayList;
import java.util.Set;
import java.util.stream.Collectors;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Context;

import org.eclipse.microprofile.jwt.JsonWebToken;
import javax.ws.rs.core.SecurityContext;
import java.security.Principal;

@RequestScoped
@Path("jwt")
public class JwtEndpoint {

    @Inject
    private JsonWebToken jwtPrincipal;

    @GET
    @Path("/name")
    public Response getName() {
        return Response.ok(this.jwtPrincipal.getName()).build();
    }

    @GET
    @Path("/groups")
    public Response getGroups(@Context SecurityContext securityContext) {
        Set<String> groups = null;
        Principal user = securityContext.getUserPrincipal();
        if (user instanceof JsonWebToken) {
            JsonWebToken jwt = (JsonWebToken) user;
            groups = jwt.getGroups();
        }
        return Response.ok(groups.toString()).build();
    }

    @GET
    @Path("/rawtoken")
    public String getRawToken() {
        return jwtPrincipal.getRawToken();
    }

    @GET
    @Path("/scope")
    public String getScope() {
      StringBuilder scope = new StringBuilder();
      ((ArrayList) jwtPrincipal.getClaim("scope")).forEach(scope::append);
      return scope.toString();
    }

}
