//
//  TTViewController.m
//  UITableViewSearch
//
//  Created by sergey on 4/28/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTViewController.h"
#import "TTStudent.h"
#import "TTSection.h"

typedef enum {
    TTSortDate,
    TTSortName,
    TTSortLastName
}TTSortType;

@interface TTViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (weak,nonatomic) UITableView *tabelView;
@property (weak,nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) NSArray* studentArray;
@property (strong, nonatomic) NSArray* sectionsArray;

@property (strong,nonatomic) NSThread* thread;

@property (assign,nonatomic) NSInteger controlState;

@end

@implementation TTViewController

- (void)loadView {
    [super loadView];
    
    CGRect rect = self.view.bounds;
    rect.origin = CGPointZero;
    
    UITableView *tabelView = [[UITableView alloc]initWithFrame:rect style:UITableViewStylePlain];
    tabelView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    tabelView.dataSource = self;
    tabelView.delegate = self;
    tabelView.separatorInset = UIEdgeInsetsZero;
    
    [self.view addSubview:tabelView];
    self.tabelView = tabelView;
    
    UISegmentedControl *control = [[UISegmentedControl alloc]initWithItems:@[@"Date",@"Name",@"Lastname"]];
    [control addTarget:self action:@selector(sortStudentControl:) forControlEvents:UIControlEventValueChanged];
    control.selectedSegmentIndex = TTSortDate;
    self.controlState = TTSortDate;
    self.navigationItem.titleView = control;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchShow:)];
    
    self.navigationItem.leftBarButtonItem = item;
    
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    Ученик.
//    
//    1. Создайте класс студента. У него должны быть свойства: имя, фамилия и год рождения.
//    2. Генерируйте случайное количество студентов и отобразите их в вашей таблице. (слева имя и фамилия, а справа дата рождения)
//    
//    Студент.
//    
//    3. Сгрупируйте студентов по секциям месяцев рождения, то есть все кто родился в январе в одной секции, а если в феврале никто не родился, то и секции такой нет.
//    4. Внутри секции студенты должны быть отсортированы по имени по алфавиту, а если имена одинаковы, то и по фамилии (подсказка, лучше отсортировать массив вначале по 3 всем параметрам: дата, имя и фамилия)
//    5. Добавьте индекс бар для быстрого перехода по секциям
//    
//    Мастер.
//    
//    6. Добавьте серчбар как в видео, чтобы кнопочка кенсел анимировано добавлялась/уезжала и тд
//    7. Фильтруйте студентов каждый раз, когда вводится новая буква, причем совпадения ищите как в имени так и в фамилии
//    
//    Супермен
//    
//    8. Добавьте к серчбару сегментед контрол с тайтлами: Год рождения, Имя, фамилия (по умолчанию включен год рождения)
//    9. Когда пользователь переключает сегментед контрол, то секции меняются на соответствующие. Например если выбран контрол с именем, то студенты должны быть отсортированы по имя-фамилия-дата, и должны быть собраны в секции, соответствующие первой букве имени.
//    10. То же самое и для фамилий, фильтр = фамилия-дата-имя
//    11. если выбрана дата, то все должно отсортироваться как в начале.
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityView.color = [UIColor blackColor];
    
    activityView.center=self.view.center;
    
    [self.view addSubview:activityView];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [activityView startAnimating];
        
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        
        for (int i = 0; i < 1000; i++) {
            
            TTStudent *student = [TTStudent getRandomStudent];
            [tempArray addObject:student];
        }
        
        self.studentArray = [self sortArray:tempArray forType:TTSortDate];
        
        self.sectionsArray = [self generateSectionsFromArray:self.studentArray withFilter:self.searchBar.text];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self.tabelView reloadData];
            [activityView stopAnimating];
        });
        
    });
    
}

#pragma mark - Methods

- (NSArray *)sortArray:(NSArray *)array forType:(TTSortType)type {
    
    NSArray *sorted;
    NSSortDescriptor *firstName = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *lastName = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    
    switch (type) {
        case TTSortDate:
        {
            NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:array];
            [tmpArray sortUsingDescriptors:[NSArray arrayWithObjects:firstName, lastName, nil]];
            sorted = [self sortDateArray:tmpArray];
            
            return sorted;
        }
            break;
        case TTSortLastName:
        {
            sorted = [self sortDateArray:array];
            NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:sorted];
            [tmpArray sortUsingDescriptors:[NSArray arrayWithObjects:lastName,firstName, nil]];
            
            return tmpArray;
        }
            break;
        case TTSortName:
        {
            sorted = [self sortDateArray:array];
            NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:sorted];
            [tmpArray sortUsingDescriptors:[NSArray arrayWithObjects:firstName,lastName, nil]];
                
            return tmpArray;
        }
            break;
        default:
            break;
    }
    
    return sorted;
    
}

- (NSArray *)sortDateArray:(NSArray *)array {
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"MM"];
    
    NSArray *sorted = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSString *str1 = [df stringFromDate:[obj1 bornDate]];
        NSString *str2 = [df stringFromDate:[obj2 bornDate]];
        return [str1 compare:str2];
        
    }];
    
    return sorted;
}

- (void)sortStudentControl:(UISegmentedControl *)sender {
    
    self.controlState = sender.selectedSegmentIndex;
    
    self.studentArray = [self sortArray:self.studentArray forType:(TTSortType)sender.selectedSegmentIndex];
    
    self.sectionsArray = [self generateSectionsFromArray:self.studentArray withFilter:self.searchBar.text];
    
    [self.tabelView reloadData];
    
}

- (void)searchShow:(UIBarButtonItem *)sender {
    
    
    UIBarButtonSystemItem item = UIBarButtonSystemItemEdit;
    
    
    if ([self.navigationItem.titleView isKindOfClass:[UISearchBar class]]) {
        
        item = UIBarButtonSystemItemSearch;
        
        UISegmentedControl *control = [[UISegmentedControl alloc]initWithItems:@[@"Date",@"Name",@"Lastname"]];
        [control addTarget:self action:@selector(sortStudentControl:) forControlEvents:UIControlEventValueChanged];
        control.selectedSegmentIndex = self.controlState;
        self.navigationItem.titleView = control;
        
    } else {
        
        UISearchBar *searchBar = [[UISearchBar alloc]init];
        self.searchBar = searchBar;
        self.searchBar.delegate = self;
        self.navigationItem.titleView = self.searchBar;
        
    }
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:item target:self action:@selector(searchShow:)];
    
    [self.navigationItem setLeftBarButtonItem:leftButton animated:YES];
    
}

- (void)generateSectionsInBackgroundFromArray:(NSArray*) array withFilter:(NSString*) filterString {

    if ([self.thread isExecuting]) {
        [self.thread cancel];
    }
    self.thread = [[NSThread alloc]initWithTarget:self selector:@selector(searchThread) object:nil];
    self.thread.name = @"search";
    [self.thread start];
}

- (void)searchThread {
    
    self.sectionsArray = [self generateSectionsFromArray:self.studentArray withFilter:self.searchBar.text];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tabelView reloadData];
    });
}

- (NSArray*) generateSectionsFromArray:(NSArray*)array withFilter:(NSString*) filterString {
    
    NSMutableArray* sectionsArray = [NSMutableArray array];
    
    NSString* currentLetter = nil;
    
    for (TTStudent* obj in array) {
        
        if ([filterString length] > 0 && [obj.firstName rangeOfString:filterString].location == NSNotFound && [obj.lastName rangeOfString:filterString].location == NSNotFound) {
            continue;
        }
        
        NSString *firstLetter;
        
        if (self.controlState == TTSortDate) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            
            [formatter setDateFormat:@"MMM"];
            
            firstLetter = [formatter stringFromDate:obj.bornDate];
        } else if (self.controlState == TTSortName) {
            firstLetter = [obj.firstName substringToIndex:1];
        } else if (self.controlState == TTSortLastName) {
            firstLetter = [obj.lastName substringToIndex:1];
        }

        TTSection* section = nil;
        
        if (![currentLetter isEqualToString:firstLetter]) {
            section = [[TTSection alloc] init];
            section.name = firstLetter;
            section.item = [NSMutableArray array];
            currentLetter = firstLetter;
            [sectionsArray addObject:section];
        } else {
            section = [sectionsArray lastObject];
        }
        
        [section.item addObject:obj];
        
    }
    
    return sectionsArray;
}



#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.sectionsArray objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    TTSection *obj = [self.sectionsArray objectAtIndex:section];
    return [obj.item count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    TTSection *obj = [self.sectionsArray objectAtIndex:indexPath.section];
    
    TTStudent *student = [obj.item objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",student.firstName, student.lastName];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"dd MMM yyyy"];
    
    NSString *stringFromDate = [formatter stringFromDate:student.bornDate];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",stringFromDate];
    
    return cell;

}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    NSMutableArray* array = [NSMutableArray array];
    
    for (TTSection* section in self.sectionsArray) {
        [array addObject:section.name];
    }
    
    return array;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sectionsArray count];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self generateSectionsInBackgroundFromArray:self.studentArray withFilter:self.searchBar.text];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
