package application.rest;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Response;

import com.ibm.websphere.security.jwt.Claims;
import com.ibm.websphere.security.jwt.JwtBuilder;

@Path("tokens")
public class TokensEndpoint {

    @GET
    @Path("/{username}")
    public String getJwt(
      @PathParam("username") String username,
      @QueryParam("scope") String scope) throws Exception {
      return JwtBuilder.create("jwtBuilder")
        .claim(Claims.SUBJECT, username)
        .claim("upn", username)
        .claim("user_name", username)
        .claim("scope", scope)
        .buildJwt().compact();
    }

}
