package se.ifmo.pepe.cwdb.backend.repo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;
import se.ifmo.pepe.cwdb.backend.customtype.PatentDistribution;
import se.ifmo.pepe.cwdb.backend.model.Trademarks;

import java.math.BigDecimal;
import java.util.List;

public interface TrademarkRepo extends JpaRepository<Trademarks, Long>, CrudRepository<Trademarks, Long> {
    @Query("select c from Trademarks c where lower(c.name) like lower(concat('%', :searchTerm, '%'))")
    List<Trademarks> searchByName(@Param("searchTerm") String searchTerm);


    @Procedure(procedureName = "add_trademark")
    Integer addTrademark(Integer _company_id, Integer _drug_id, String name,
                         BigDecimal _doze, BigDecimal _release_price, String _distribution);

    @Procedure(procedureName = "update_trademark")
    Integer updateTrademark(Integer _company_id, Integer _patent_id, Integer _drug_id, String name,
                         BigDecimal _doze, BigDecimal _release_price, String _distribution);

}
