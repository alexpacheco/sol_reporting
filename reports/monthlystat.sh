#!/bin/bash


prevmonthstart=$(date -d "yesterday" +%Y-%m-01)
prevmonthend=$(date -d "yesterday" +%Y-%m-%d)
yesterday=$(date -d "yesterday" +"%b %d, %Y")

cd /home/alp514/usage


cat << EOF > piusage.html
<!doctype html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en-us">
  <head>
    <link rel="stylesheet" href="style.css">
  </head>
  <body>
    <div class="row">
      <div class="column left">
    <aside>
    <nav>
      <ul>
        <li>Usage Reports
          <ul>
            <li><a href="index.html">By PI</a></li>
            <li><a href="usagestat.html">By Month</a></li>
            <li><a href="partition.html">By Partition</a></li>
          </ul>
        </li>
        <li>Annual Summary
          <ul>
            <li><a href="piusage.html">By PI</a></li>
            <li><a href="pidept.html">By PI Department</a></li>
            <li><a href="userdept.html">By User Department</a></li>
          </ul>
        </li>
      </ul>
    </nav>
    </aside>
      </div>
      <div class="column right">
    <article>
    <section> 
    <h2>AY 2017-18 Usage per PI</h2>
    <p>Usage through ${yesterday}</p>
    <br />
    <br />
       <table>
         <tr><th>PI</th><th>Department</th><th>SUs Consumed</th><th>&#35; Jobs</th></tr>
EOF
./getmonthlystats.sh 2017-10-01 ${prevmonthend} >> piusage.html 2>/dev/null 
cat << EOF >> piusage.html
       </table>
    <br />
    <br />
    <h2>AY 2016-17 Usage per PI</h2>
    <br />
    <br />
       <table>
         <tr><th>PI</th><th>Department</th><th>SUs Consumed</th><th>&#35; Users</th><th>&#35; Jobs</th></tr>
         <tr><td>Wonpil Im            </td><td> Biological Sciences           </td><td> 3161733.22  </td><td>  28</td><td> 187711 </td></tr>  
         <tr><td>Srinivas Rangarajan  </td><td> Chemical  Biomolecular Engineering    </td><td> 1032016.22  </td><td>  5 </td><td> 2951 </td></tr>  
         <tr><td>Edmund B. Webb       </td><td> Mechanical Engineering  Mechanics   </td><td> 489728.55   </td><td>  8 </td><td> 2695 </td></tr> 
         <tr><td>Alparslan Oztekin    </td><td> Mechanical Engineering  Mechanics   </td><td> 380143.58   </td><td>  6 </td><td> 782 </td></tr>  
         <tr><td>James Gunton         </td><td> Physics                   </td><td> 240451.31   </td><td>  4 </td><td> 633 </td></tr>  
         <tr><td>Dimitrios Vavylonis  </td><td> Physics                   </td><td> 123604.46   </td><td>  3 </td><td> 268 </td></tr>  
         <tr><td>RC Staff             </td><td> LTS                   </td><td> 51790.48    </td><td>  5 </td><td> 2824 </td></tr> 
         <tr><td>CHE395               </td><td> Chemical Engineering           </td><td> 41505.14    </td><td>  17</td><td> 3424 </td></tr>  
         <tr><td>Robert Flowers       </td><td> Chemistry               </td><td> 30764.55    </td><td>  3 </td><td> 1443 </td></tr> 
         <tr><td>Tara Jeanne Troy     </td><td> Civil  Environmental Engineering   </td><td> 23879.30    </td><td>  1 </td><td> 985 </td></tr>  
         <tr><td>Jeetain Mittal       </td><td> Chemical  Biomolecular Engineering   </td><td> 23057.73    </td><td>  3 </td><td> 932 </td></tr>  
         <tr><td>Brian Chen           </td><td> Computer Science  Engineering       </td><td> 21655.01    </td><td>  2 </td><td> 449 </td></tr>  
         <tr><td>Bruce Dodson         </td><td> Mathematics               </td><td> 20104.05    </td><td>  1 </td><td> 35 </td></tr>  
         <tr><td>Anand Jagota         </td><td> Chemical  Biomolecular Engineering   </td><td> 18672.42    </td><td>  6 </td><td> 663 </td></tr>  
         <tr><td>Julie Haas           </td><td> Biological Sciences           </td><td> 16929.47    </td><td>  1 </td><td> 381 </td></tr>  
         <tr><td>Richard Sause        </td><td> Civil  Environmental Engineering   </td><td> 8415.44     </td><td>  1 </td><td> 345 </td></tr>  
         <tr><td>Ganesh Balasubramanian </td><td> Mechanical Engineering  Mechanics    </td><td> 4900.37     </td><td>  1 </td><td> 15 </td></tr>
         <tr><td>Frank Zhang          </td><td> Mechanical Engineering  Mechanics   </td><td> 4870.18     </td><td>  1 </td><td> 21 </td></tr>  
         <tr><td>Peter Bryan          </td><td> Engineering Research Center - ATLSS   </td><td> 189.13      </td><td>  1 </td><td> 84 </td></tr>
         <tr><td>CSE498               </td><td> Computer Science  Engineering        </td><td> 18.48       </td><td>  4 </td><td> 27 </td></tr>  
         <strong>
         <tr><td>Total                </td><td>                                        </td><td> 5694429.75  </td><td> 102 </td><td> 206651 </td></tr>
         </strong>
       </table>

    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    </section>
    </article>
    </div>
    </div>
  </body>
</html> 
EOF

